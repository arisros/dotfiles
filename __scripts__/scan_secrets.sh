#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./__scripts__/scan_secrets.sh [--tracked|--staged]

  --tracked  Scan all tracked files (default)
  --staged   Scan only staged files
EOF
}

mode="${1:---tracked}"

case "$mode" in
  --tracked|--staged) ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "secret-scan: run this inside a git repository" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

candidates=()
if [ "$mode" = "--staged" ]; then
  while IFS= read -r file; do
    [ -n "$file" ] && candidates+=("$file")
  done < <(git diff --cached --name-only --diff-filter=ACMRT)
else
  while IFS= read -r file; do
    [ -n "$file" ] && candidates+=("$file")
  done < <(git ls-files)
fi

scan_files=()
if [ "${#candidates[@]}" -gt 0 ]; then
  for file in "${candidates[@]}"; do
    if [ -f "$file" ]; then
      scan_files+=("$file")
    fi
  done
fi

if [ "${#scan_files[@]}" -eq 0 ]; then
  echo "secret-scan: no files to scan ($mode)."
  exit 0
fi

declare -a checks=(
  "Private key block|-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----"
  "AWS access key (AKIA)|AKIA[0-9A-Z]{16}"
  "AWS temp key (ASIA)|ASIA[0-9A-Z]{16}"
  "GitHub personal token|ghp_[A-Za-z0-9]{36}"
  "GitHub fine-grained token|github_pat_[A-Za-z0-9_]{20,}"
  "Google API key|AIza[0-9A-Za-z_-]{35}"
  "Slack token|xox[baprs]-[A-Za-z0-9-]{10,}"
  "OpenAI-style secret key|sk-[A-Za-z0-9-]{20,}"
)

found=0

for check in "${checks[@]}"; do
  label="${check%%|*}"
  regex="${check#*|}"

  set +e
  matches="$(grep -nI -E "$regex" "${scan_files[@]}" 2>/dev/null)"
  status=$?
  set -e

  if [ "$status" -eq 0 ] && [ -n "$matches" ]; then
    found=1
    echo ""
    echo "[secret-scan] $label"
    echo "$matches"
  fi
done

if [ "$found" -eq 1 ]; then
  cat <<'EOF' >&2

secret-scan: potential secrets detected.
Fix before committing/pushing.
EOF
  exit 1
fi

echo "secret-scan: no high-confidence secret patterns found in ${#scan_files[@]} files ($mode)."
