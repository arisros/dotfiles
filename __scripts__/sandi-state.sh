#!/usr/bin/env bash

set -euo pipefail

STORE="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
FETCH=1

usage() {
  cat <<'EOF'
Usage: ./__scripts__/sandi-state.sh [--no-fetch]

Prints one line describing the sync state of the password store. This is the
single source of truth: the sandi shell function and the sketchybar plugin both
call it rather than reimplementing the checks.

  synced            in sync with the remote, nothing uncommitted
  ahead N           N local commits not pushed
  behind N          N remote commits not pulled
  diverged N M      N ahead and M behind
  dirty N           N uncommitted changes in the store
  nostore           store directory does not exist
  nogit             store is not a git repository
  noremote          no remote configured at all
  unpushed          remote configured, but no upstream branch yet
  offline           remote unreachable

  --no-fetch        report from local refs only, no network round trip
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-fetch)
      FETCH=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf '[sandi] unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ ! -d "$STORE" ]; then
  printf 'nostore\n'
  exit 0
fi

if ! git -C "$STORE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'nogit\n'
  exit 0
fi

dirty="$(git -C "$STORE" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
if [ "$dirty" -gt 0 ]; then
  printf 'dirty %s\n' "$dirty"
  exit 0
fi

if ! git -C "$STORE" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
  if git -C "$STORE" remote get-url origin >/dev/null 2>&1; then
    printf 'unpushed\n'
  else
    printf 'noremote\n'
  fi
  exit 0
fi

if [ "$FETCH" -eq 1 ]; then
  if ! git -C "$STORE" fetch --quiet 2>/dev/null; then
    printf 'offline\n'
    exit 0
  fi
fi

ahead="$(git -C "$STORE" rev-list --count '@{u}..HEAD' 2>/dev/null || printf '0')"
behind="$(git -C "$STORE" rev-list --count 'HEAD..@{u}' 2>/dev/null || printf '0')"

if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
  printf 'diverged %s %s\n' "$ahead" "$behind"
elif [ "$ahead" -gt 0 ]; then
  printf 'ahead %s\n' "$ahead"
elif [ "$behind" -gt 0 ]; then
  printf 'behind %s\n' "$behind"
else
  printf 'synced\n'
fi
