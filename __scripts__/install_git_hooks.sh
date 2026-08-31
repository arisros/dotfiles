#!/usr/bin/env bash

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "install_git_hooks: run this inside the target git repository" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
hooks_src_dir="$repo_root/.githooks"
hooks_dst_dir="$repo_root/.git/hooks"

if [ ! -d "$hooks_src_dir" ]; then
  echo "install_git_hooks: missing hooks source directory: $hooks_src_dir" >&2
  exit 1
fi

mkdir -p "$hooks_dst_dir"

installed=0
for hook in "$hooks_src_dir"/*; do
  [ -f "$hook" ] || continue
  hook_name="$(basename "$hook")"
  cp "$hook" "$hooks_dst_dir/$hook_name"
  chmod +x "$hooks_dst_dir/$hook_name"
  installed=$((installed + 1))
done

if [ "$installed" -eq 0 ]; then
  echo "install_git_hooks: no hook files found in $hooks_src_dir" >&2
  exit 1
fi

echo "install_git_hooks: installed $installed hook(s) into $hooks_dst_dir"
