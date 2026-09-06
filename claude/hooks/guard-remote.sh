#!/usr/bin/env bash
# Guard: nothing may mutate a git remote / origin (or team systems) without
# explicit approval. Returns a PreToolUse permissionDecision of:
#   deny -> irreversible remote history / topology changes (do these yourself)
#   ask  -> normal outward-facing writes (push, PR create/merge, ...)
# Everything else: no output = no effect.
# Handles the RTK hook rewrite (`git push` -> `rtk git push`).

input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

emit() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$1" "$2"
  exit 0
}

# Split the command line into segments so `cd repo && git push --force` is seen.
segments=$(printf '%s' "$cmd" | tr '\n' ';' | sed -E 's/&&/;/g; s/\|\|/;/g; s/\|/;/g' | tr ';' '\n')

while IFS= read -r seg; do
  [ -z "$seg" ] && continue
  # strip leading whitespace, sudo, and the rtk / rtk proxy wrapper
  s=$(printf '%s' "$seg" | sed -E 's/^[[:space:]]+//; s/^(sudo[[:space:]]+)?//; s/^rtk[[:space:]]+(proxy[[:space:]]+)?//')

  # --- git push -------------------------------------------------------------
  if printf '%s' "$s" | grep -qE '^git([[:space:]]+-[^[:space:]]+)*[[:space:]]+push([[:space:]]|$)'; then
    if printf '%s' "$s" | grep -qE '([[:space:]])(--force([[:space:]]|=|$)|-f([[:space:]]|$)|--force-with-lease|--mirror|--delete([[:space:]]|$)|-d([[:space:]]|$)|--prune)'; then
      emit deny "Force/delete push to a remote is blocked by your global guard. Run it yourself if you really want it."
    fi
    if printf '%s' "$s" | grep -qE '[[:space:]]\+[^[:space:]]+:'; then
      emit deny "Forced refspec push (+src:dst) is blocked by your global guard."
    fi
    emit ask "This pushes to a remote (origin). Approve only if you meant to."
  fi

  # --- git remote topology --------------------------------------------------
  if printf '%s' "$s" | grep -qE '^git([[:space:]]+-[^[:space:]]+)*[[:space:]]+remote[[:space:]]+(set-url|add|remove|rm|rename|prune|set-head|set-branches)'; then
    emit deny "Changing git remote configuration is blocked by your global guard."
  fi

  # --- gh: irreversible -----------------------------------------------------
  if printf '%s' "$s" | grep -qE '^gh[[:space:]]+repo[[:space:]]+(delete|archive|rename|transfer)'; then
    emit deny "Destructive gh repo operation is blocked by your global guard."
  fi

  # --- gh: outward-facing writes -------------------------------------------
  if printf '%s' "$s" | grep -qE '^gh[[:space:]]+pr[[:space:]]+(create|merge|close|reopen|edit|review|comment|ready|lock|unlock)'; then
    emit ask "This writes to a pull request on the remote. Approve only if you meant to."
  fi
  if printf '%s' "$s" | grep -qE '^gh[[:space:]]+issue[[:space:]]+(create|close|reopen|edit|comment|delete|transfer|pin|lock)'; then
    emit ask "This writes to an issue on the remote. Approve only if you meant to."
  fi
  if printf '%s' "$s" | grep -qE '^gh[[:space:]]+(release|workflow|run|repo|cache|secret|variable|label|ruleset)[[:space:]]+(create|delete|edit|upload|run|enable|disable|rerun|cancel|set|clone)'; then
    emit ask "This changes remote repository state via gh. Approve only if you meant to."
  fi
  if printf '%s' "$s" | grep -qE '^gh[[:space:]]+api[[:space:]]+graphql' && \
     printf '%s' "$s" | grep -qE '\bmutation\b'; then
    emit ask "This is a GraphQL mutation against the remote. Approve only if you meant to."
  fi
  if printf '%s' "$s" | grep -qE '^gh[[:space:]]+api[[:space:]]' && \
     printf '%s' "$s" | grep -qiE '(-X|--method)[[:space:]]+(POST|PUT|PATCH|DELETE)'; then
    emit ask "This is a writing gh api call against the remote. Approve only if you meant to."
  fi
done <<< "$segments"

exit 0
