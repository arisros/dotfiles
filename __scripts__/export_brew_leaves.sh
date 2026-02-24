#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_FILE="${1:-$SCRIPT_DIR/brew-leaves.txt}"

if ! command -v brew >/dev/null 2>&1; then
  printf 'export_brew_leaves: brew is not installed on this machine\n' >&2
  exit 1
fi

tmp_file="$(mktemp)"
brew leaves | grep -E '^[A-Za-z0-9@._+/-]+$' | sort -u > "$tmp_file"
mv "$tmp_file" "$OUT_FILE"

printf 'export_brew_leaves: wrote %s\n' "$OUT_FILE"
