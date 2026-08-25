#!/usr/bin/env python3
"""Terminal dashboard for RunPod pods.

Reads the API key from ~/.runpod/key (or $RUNPOD_API_KEY) and polls the
RunPod GraphQL API. Stdlib only.

  ./rpdash.py            # live, refresh every 5s
  ./rpdash.py -n 15      # refresh every 15s
  ./rpdash.py --once     # print once and exit (nice for scripts)
"""

import argparse
import json
import os
import shutil
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime

API = "https://api.runpod.io/graphql"
KEY_FILE = os.path.expanduser("~/.runpod/key")

QUERY = """
query {
  myself {
    clientBalance
    currentSpendPerHr
    pods {
      id
      name
      desiredStatus
      costPerHr
      gpuCount
      vcpuCount
      memoryInGb
      volumeInGb
      imageName
      machine { gpuDisplayName }
      runtime {
        uptimeInSeconds
        gpus { gpuUtilPercent memoryUtilPercent }
        container { cpuPercent memoryPercent }
        ports { ip publicPort privatePort type isIpPublic }
      }
    }
  }
}
"""

# ---------- ansi ----------
R = "\033[0m"
B = "\033[1m"
DIM = "\033[2m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
CYAN = "\033[36m"
GREY = "\033[90m"

STATUS_COLOR = {
    "RUNNING": GREEN,
    "EXITED": GREY,
    "TERMINATED": GREY,
    "PAUSED": YELLOW,
}


def load_key():
    key = os.environ.get("RUNPOD_API_KEY")
    if key:
        return key.strip()
    try:
        with open(KEY_FILE) as f:
            return f.read().strip()
    except OSError as e:
        sys.exit(f"cannot read API key from {KEY_FILE} or $RUNPOD_API_KEY: {e}")


def fetch(key):
    req = urllib.request.Request(
        f"{API}?api_key={key}",
        data=json.dumps({"query": QUERY}).encode(),
        # the default urllib UA gets 403'd by RunPod's edge
        headers={"content-type": "application/json", "user-agent": "rpdash/1.0"},
    )
    with urllib.request.urlopen(req, timeout=20) as resp:
        body = json.load(resp)
    if "errors" in body:
        raise RuntimeError(body["errors"][0].get("message", "graphql error"))
    return body["data"]["myself"]


def fmt_uptime(secs):
    if not secs:
        return "-"
    d, rem = divmod(int(secs), 86400)
    h, rem = divmod(rem, 3600)
    m = rem // 60
    if d:
        return f"{d}d{h:02d}h"
    if h:
        return f"{h}h{m:02d}m"
    return f"{m}m"


def bar(pct, width=10):
    pct = max(0, min(100, int(pct or 0)))
    filled = round(pct * width / 100)
    color = GREEN if pct < 60 else (YELLOW if pct < 90 else RED)
    return f"{color}{'█' * filled}{GREY}{'·' * (width - filled)}{R} {pct:3d}%"


def render(me, interval, width):
    out = []
    bal = me.get("clientBalance") or 0.0
    spend = me.get("currentSpendPerHr") or 0.0
    pods = me.get("pods") or []
    running = [p for p in pods if p.get("desiredStatus") == "RUNNING"]

    runway = f"{bal / spend:.1f}h" if spend > 0 else "∞"
    bal_color = GREEN if spend <= 0 or bal / spend > 24 else (YELLOW if bal / spend > 6 else RED)

    now = datetime.now().strftime("%H:%M:%S")
    out.append(f"{B}RunPod{R}  {DIM}{now}{R}")
    out.append(
        f"  balance {bal_color}${bal:,.2f}{R}"
        f"   burn {CYAN}${spend:.3f}/hr{R}"
        f"   runway {bal_color}{runway}{R}"
        f"   pods {len(running)}/{len(pods)} running"
    )
    out.append("")

    if not pods:
        out.append(f"  {DIM}no pods{R}")
    for p in pods:
        st = p.get("desiredStatus", "?")
        col = STATUS_COLOR.get(st, YELLOW)
        rt = p.get("runtime") or {}
        gpus = rt.get("gpus") or []
        cont = rt.get("container") or {}
        gpu_name = (p.get("machine") or {}).get("gpuDisplayName") or "?"
        n = p.get("gpuCount") or 0
        up = rt.get("uptimeInSeconds")
        cost = p.get("costPerHr") or 0.0
        spent = cost * (up or 0) / 3600

        out.append(
            f"{col}●{R} {B}{p.get('name','')}{R} {DIM}{p.get('id','')}{R}"
            f"  {col}{st}{R}"
        )
        out.append(
            f"    {n}x {gpu_name}  {DIM}·{R} {p.get('vcpuCount')} vCPU"
            f"  {DIM}·{R} {p.get('memoryInGb')}GB RAM"
            f"  {DIM}·{R} {p.get('volumeInGb')}GB vol"
        )
        out.append(
            f"    up {fmt_uptime(up)}  {DIM}·{R} ${cost:.2f}/hr"
            f"  {DIM}·{R} this session ${spent:.2f}"
        )
        if gpus:
            for i, g in enumerate(gpus):
                out.append(
                    f"    gpu{i}  {bar(g.get('gpuUtilPercent'))}"
                    f"   vram {bar(g.get('memoryUtilPercent'))}"
                )
        if cont:
            out.append(
                f"    cpu   {bar(cont.get('cpuPercent'))}"
                f"   ram  {bar(cont.get('memoryPercent'))}"
            )
        for port in rt.get("ports") or []:
            if port.get("privatePort") == 22 and port.get("isIpPublic"):
                out.append(
                    f"    {DIM}ssh root@{port['ip']} -p {port['publicPort']}{R}"
                )
        img = p.get("imageName") or ""
        if img:
            out.append(f"    {GREY}{img[: max(20, width - 6)]}{R}")
        out.append("")

    out.append(f"{DIM}refresh {interval}s · ctrl-c to quit{R}")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description="RunPod terminal dashboard")
    ap.add_argument("-n", "--interval", type=float, default=5, help="refresh seconds")
    ap.add_argument("--once", action="store_true", help="print once and exit")
    args = ap.parse_args()

    key = load_key()
    err = None
    while True:
        width = shutil.get_terminal_size((100, 30)).columns
        try:
            me = fetch(key)
            err = None
            screen = render(me, args.interval, width)
        except (urllib.error.URLError, RuntimeError, TimeoutError, json.JSONDecodeError) as e:
            err = str(e)
            screen = f"{RED}error:{R} {err}"

        if args.once:
            print(screen)
            return 1 if err else 0

        # clear + home, then draw
        sys.stdout.write("\033[H\033[J" + screen)
        sys.stdout.flush()
        try:
            time.sleep(args.interval)
        except KeyboardInterrupt:
            sys.stdout.write("\n")
            return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(0)
