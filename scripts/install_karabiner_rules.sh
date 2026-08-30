#!/usr/bin/env bash
# Enable this repo's Karabiner complex modifications without the GUI.
#
# Karabiner has no CLI for this: karabiner_cli can lint a rule file but cannot
# enable one. Adding a rule in the GUI copies it out of
# assets/complex_modifications/ and into the *selected profile* inside
# karabiner.json, so that is what this script does directly.
#
# Idempotent: rules are matched by description, replaced if already present,
# appended in source order otherwise. Safe to re-run after editing the rules.
set -euo pipefail

SRC_DEFAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/macos/karabiner/tmux-browser.json"
SRC="${1:-$SRC_DEFAULT}"
CONFIG="$HOME/.config/karabiner/karabiner.json"
CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

log()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$*" >&2; }
err()  { printf "\033[1;31m==>\033[0m %s\n" "$*" >&2; }

[ "$(uname -s)" = "Darwin" ] || { log "not macOS — skipping Karabiner rules"; exit 0; }

if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found (it is in packages/Brewfile) — skipping Karabiner rules"
    exit 0
fi

[ -f "$SRC" ] || { err "rule file not found: $SRC"; exit 1; }

# Every rule this repo manages carries this prefix; anything else in the profile
# belongs to the user and is left alone.
TAG="[dotfiles] "
if [ "$(jq --arg t "$TAG" '[.rules[] | select((.description // "") | startswith($t))] | length' "$SRC")" \
   != "$(jq '.rules | length' "$SRC")" ]; then
    err "every rule in $SRC must have a description starting with '$TAG'"
    exit 1
fi

if [ ! -f "$CONFIG" ]; then
    warn "$CONFIG does not exist yet."
    warn "Launch Karabiner-Elements once so it writes a default profile, then re-run:"
    warn "  bash ${BASH_SOURCE[0]}"
    exit 0
fi

# Validate before touching a working config. Older builds lack the flag, so a
# non-zero exit only aborts when the linter actually reported a problem.
if [ -x "$CLI" ]; then
    if ! "$CLI" --lint-complex-modifications "$SRC" >/dev/null 2>&1; then
        if "$CLI" --lint-complex-modifications "$SRC" 2>&1 | grep -qi "error"; then
            err "karabiner_cli rejected $SRC — not touching karabiner.json"
            "$CLI" --lint-complex-modifications "$SRC" || true
            exit 1
        fi
    fi
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Managed rules are identified by the TAG in their description, not by the whole
# string. Matching on the full description meant that renaming a rule left the
# old copy behind — and since a stale copy sits earlier in the list, it would
# keep binding Home and silently shadow the new one.
jq --slurpfile new "$SRC" --arg tag "$TAG" '
  ($new[0].rules) as $newrules
  | (((.profiles | map(.selected == true) | index(true)) // 0)) as $i
  | .profiles[$i].complex_modifications.rules =
      (((.profiles[$i].complex_modifications.rules // [])
        | map(select((.description // "") | startswith($tag) | not)))
       + $newrules)
' "$CONFIG" > "$tmp"

# Sanity-check the result before it replaces a working config.
jq -e '.profiles | length > 0' "$tmp" >/dev/null || {
    err "merge produced an invalid config — left $CONFIG untouched (backup: $backup)"
    exit 1
}

# Nothing to do if the merge is a no-op. Bailing out here keeps repeat runs of
# install.sh from piling up backups and from nudging Karabiner to reload.
if cmp -s "$tmp" "$CONFIG"; then
    log "Karabiner rules already up to date"
    exit 0
fi

# Only now is a backup worth writing — and only reachable once the merge has
# been built and validated, so a failure never leaves a stray one behind.
backup="$CONFIG.bak.$(date +%Y%m%d%H%M%S)"
cp "$CONFIG" "$backup"

# Overwrite in place rather than mv: keeping the inode is what lets Karabiner's
# file watcher notice the change and reload without a restart.
cat "$tmp" > "$CONFIG"

profile="$(jq -r '(.profiles[] | select(.selected == true) | .name) // .profiles[0].name' "$CONFIG")"
count="$(jq '[.rules[].description] | length' "$SRC")"
log "enabled $count rule(s) in Karabiner profile \"$profile\""
jq -r '.rules[] | "    - " + .description' "$SRC" | cut -c1-100
log "backup: $backup"
