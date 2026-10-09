#!/usr/bin/env bash
# Bring a machine up to date with the repo: everything install.sh clones once and never refreshes.
# Usage: dots-sync.sh [--no-pull]

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
PULL=1
failures=()

for arg in "$@"; do
  case "$arg" in
    --no-pull) PULL=0 ;;
    *) echo "usage: $(basename "$0") [--no-pull]" >&2; exit 2 ;;
  esac
done

log() { printf '[sync] %s\n' "$*"; }
warn() { printf '[sync][warn] %s\n' "$*" >&2; failures+=("$*"); }

pull_repo() {
  git -C "$1" pull --ff-only --quiet || warn "pull failed in $1"
}

if [ "$PULL" = "1" ]; then
  log "Pulling $REPO_DIR"
  DOTS_SYNC_RUNNING=1 git -C "$REPO_DIR" pull --ff-only --quiet || warn "pull failed in $REPO_DIR"
fi

log 'Restowing packages'
# shellcheck source=__scripts__/stow-map.sh
source "$REPO_DIR/__scripts__/stow-map.sh"
for dir in "${config_dirs[@]}"; do
  mkdir -p "$dir"
done
for pair in "${stow_pairs[@]}"; do
  target="${pair%%:*}"
  pkg="${pair#*:}"
  [ -e "$REPO_DIR/$pkg" ] || continue
  if ! out="$(cd "$REPO_DIR" && stow -R -t "$target" "$pkg" 2>&1)"; then
    printf '%s\n' "$out" >&2
    warn "stow $pkg -> $target (run ./install.sh to adopt conflicts)"
  fi
done

[ -e "$HOME/.claude/settings.json" ] || cp "$REPO_DIR/claude/settings.json" "$HOME/.claude/settings.json"

"$REPO_DIR/__scripts__/install_git_hooks.sh" >/dev/null || warn 'git hooks'

if [ "$OS" = "darwin" ]; then
  log 'Merging Karabiner rules'
  "$REPO_DIR/__scripts__/install_karabiner_rules.sh" >/dev/null || warn 'karabiner rules'
fi

tpm_dir="$HOME/.config/tmux/plugins/tpm"
if command -v tmux >/dev/null 2>&1; then
  if [ ! -d "$tpm_dir" ]; then
    git clone --quiet https://github.com/tmux-plugins/tpm "$tpm_dir" || warn 'tpm clone'
  fi
  if [ -x "$tpm_dir/bin/install_plugins" ]; then
    log 'Updating tmux plugins'
    "$tpm_dir/bin/install_plugins" >/dev/null || warn 'tpm install_plugins'
    "$tpm_dir/bin/update_plugins" all >/dev/null || warn 'tpm update_plugins'
    "$tpm_dir/bin/clean_plugins" >/dev/null || warn 'tpm clean_plugins'
  fi
  if tmux info >/dev/null 2>&1; then
    tmux source-file "$HOME/.config/tmux/tmux.conf" || warn 'tmux reload'
  fi
fi

for plugin in "$HOME"/.zsh-plugins/*/; do
  [ -d "$plugin/.git" ] || continue
  log "Updating zsh plugin $(basename "$plugin")"
  pull_repo "$plugin"
done

plugin_dir="${DOTFILES_PLUGINS:-$HOME/.config/dotfiles/plugins}"
for plugin in "$plugin_dir"/*; do
  [ -d "$plugin" ] || continue
  log "Updating dotfiles plugin $(basename "$plugin")"
  if git -C "$plugin" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    pull_repo "$plugin"
  fi
  if [ -x "$plugin/install.sh" ]; then
    "$plugin/install.sh" >/dev/null || warn "plugin $(basename "$plugin") install.sh"
  fi
done

if [ "${#failures[@]}" -gt 0 ]; then
  log "Done with ${#failures[@]} problem(s):"
  printf '  - %s\n' "${failures[@]}" >&2
  exit 1
fi
log 'Done'
