#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORE="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
QUIET=0

usage() {
  cat <<'EOF'
Usage: ./__scripts__/sandi-setup.sh [--quiet]

Prepares the password store for syncing. Idempotent: safe to run on every
install. It never pushes and never decrypts anything, so it cannot prompt.

  1. checks that pass and gpg are present
  2. git init inside the store if it is not a repository yet
  3. wires the remote from $SANDI_REMOTE if one is set and none exists
  4. installs the post-commit hook that pushes in the background
  5. prints the resulting sync state

Set the remote per machine, not in this repo:

  # ~/.config/dotfiles/modules/sandi.zsh
  export SANDI_REMOTE="yourhost:path/to/password-store.git"

  --quiet   reduce output
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --quiet)
      QUIET=1
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

log() {
  if [ "$QUIET" -eq 0 ]; then
    printf '[sandi] %s\n' "$*"
  fi
}

warn() {
  printf '[sandi] %s\n' "$*" >&2
}

if ! command -v pass >/dev/null 2>&1; then
  log 'pass not installed, nothing to set up'
  exit 0
fi

if ! command -v gpg >/dev/null 2>&1; then
  warn 'gpg not installed, pass cannot decrypt'
  exit 0
fi

if [ ! -d "$STORE" ]; then
  log "no store at $STORE, nothing to set up"
  exit 0
fi

if [ ! -f "$STORE/.gitignore" ]; then
  printf '.DS_Store\n' > "$STORE/.gitignore"
  log 'added .gitignore to the store'
fi

if ! git -C "$STORE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  pass git init >/dev/null 2>&1
  log 'initialised git in the store'
fi

# install.sh runs this from bash, where the zsh module has not been loaded, so
# read the remote out of the module rather than depending on the environment.
if [ -z "${SANDI_REMOTE:-}" ]; then
  module="${DOTFILES_MODULES:-$HOME/.config/dotfiles/modules}/sandi.zsh"
  if [ -f "$module" ]; then
    SANDI_REMOTE="$(sed -n 's/^[[:space:]]*export[[:space:]]*SANDI_REMOTE=["'"'"']\{0,1\}\([^"'"'"']*\)["'"'"']\{0,1\}[[:space:]]*$/\1/p' "$module" | tail -1)"
  fi
fi

if ! git -C "$STORE" remote get-url origin >/dev/null 2>&1; then
  if [ -n "${SANDI_REMOTE:-}" ]; then
    git -C "$STORE" remote add origin "$SANDI_REMOTE"
    log "remote origin set to $SANDI_REMOTE"
  else
    log 'SANDI_REMOTE not set, leaving the store local only'
  fi
fi

hook="$STORE/.git/hooks/post-commit"
if [ ! -f "$hook" ]; then
  cat > "$hook" <<'HOOK'
#!/usr/bin/env bash
# Installed by dotfiles __scripts__/sandi-setup.sh
# Pushes in the background so that "not synced" only ever means "was offline".
git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1 || exit 0
(git push --quiet >/dev/null 2>&1 &) >/dev/null 2>&1
exit 0
HOOK
  chmod +x "$hook"
  log 'installed post-commit auto-push hook'
fi

if [ -x "$SCRIPT_DIR/sandi-state.sh" ]; then
  log "state: $("$SCRIPT_DIR/sandi-state.sh" --no-fetch)"
fi
