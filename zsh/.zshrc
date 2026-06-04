# ============================================================================
# Portable zsh init. OS-specific bits live in .zshrc.macos / .zshrc.linux,
# which this file sources at the very end.
# ============================================================================

# Helper: source a file only if it exists, so missing optional bits don't error.
_source_if_exists() { [[ -r "$1" ]] && source "$1"; }

# ---- vi mode + history ----------------------------------------------------
set -o vi

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_FCNTL_LOCK
setopt HIST_VERIFY

autoload -Uz compinit && compinit

# ---- sourced prompt + aliases --------------------------------------------
_source_if_exists ~/git-prompt.zsh
_source_if_exists ~/.config_restart_aliases
_source_if_exists ~/.fs_aliases
_source_if_exists ~/.functions
_source_if_exists ~/.git_aliases
_source_if_exists ~/.docker_aliases
_source_if_exists ~/.cloudflare_env
_source_if_exists ~/.blue_dev
_source_if_exists ~/.arduino-cli-completion
_source_if_exists ~/.secrets

# ---- ssh-agent ------------------------------------------------------------
# Start an agent if one isn't already inherited (works on both macOS and Linux;
# on macOS the launchd plist may have already exported SSH_AUTH_SOCK).
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    eval "$(ssh-agent -s)" >/dev/null
    for key in ~/.ssh/id_ed25519_github ~/.ssh/id_rsa_git_arisjirat ~/.ssh/id_github_bfi; do
        [ -f "$key" ] && ssh-add "$key" 2>/dev/null
    done
fi

# ---- generic PATH (portable) ---------------------------------------------
# Earlier entries win. mise's shims live in ~/.local/bin.
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.composer/vendor/bin:$PATH"

# Sketchybar config dirs — harmless on Linux, used by macOS sketchybar.
export CONFIG_DIR="$HOME/.config/sketchybar"
export ITEM_DIR="$CONFIG_DIR/items"

# ---- runtime managers (single source of truth: mise) ---------------------
# nvm and fnm intentionally dropped; mise manages node/python/ruby/etc.
if [ -x "$HOME/.local/bin/mise" ]; then
    eval "$(~/.local/bin/mise activate zsh)"
fi

# SDKMAN — pinned at end of OS-specific files per its own instructions, see below.

# ---- dart completion (portable) ------------------------------------------
_source_if_exists "$HOME/.dart-cli-completion/zsh-config.zsh"

# ---- nix daemon (portable) -----------------------------------------------
_source_if_exists "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# ---- bun completion (portable) -------------------------------------------
_source_if_exists "$HOME/.bun/_bun"

# ---- opencode -------------------------------------------------------------
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# ---- private repos --------------------------------------------------------
export GOPRIVATE=github.com/bfi-finance

# ---- plugin styling (read by autosuggestions when it loads below) --------
# Suggest from history first, then completion. Dim grey so suggestions read as
# "ghost text". Ctrl-Space accepts the current suggestion.
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
bindkey '^ ' autosuggest-accept

# ---- OS-specific overrides (must be near the end) ------------------------
case "$OSTYPE" in
    darwin*)  _source_if_exists ~/.zshrc.macos ;;
    linux*)   _source_if_exists ~/.zshrc.linux ;;
esac

# ---- SDKMAN (must be last per SDKMAN's own instructions) -----------------
export SDKMAN_DIR="$HOME/.sdkman"
_source_if_exists "$SDKMAN_DIR/bin/sdkman-init.sh"
if [ -d "$SDKMAN_DIR/candidates/java/current" ]; then
    export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
    export PATH="$JAVA_HOME/bin:$PATH"
fi
