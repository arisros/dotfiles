# --- OS detection ---
_IS_MACOS=false
_IS_LINUX=false
if [[ "$OSTYPE" == darwin* ]]; then
  _IS_MACOS=true
elif [[ "$OSTYPE" == linux* ]]; then
  _IS_LINUX=true
fi

# --- macOS-only: sketchybar, CGO/Homebrew flags ---
if $_IS_MACOS; then
  export CONFIG_DIR="$HOME/.config/sketchybar"
  export ITEM_DIR="$CONFIG_DIR/items"
  export CGO_CFLAGS="-I/opt/homebrew/include"
  export CGO_LDFLAGS="-L/opt/homebrew/lib"
  export PATH="/opt/homebrew/opt/libxslt/bin:$PATH"
  export LDFLAGS="-L/opt/homebrew/opt/libxslt/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/libxslt/include"
  export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
  export PATH="/opt/homebrew/bin:$PATH"
  export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig"
fi
if command -v pkg-config >/dev/null 2>&1; then
  cgo_cppflags="$(pkg-config --cflags lept tesseract 2>/dev/null || true)"
  cgo_ldflags="$(pkg-config --libs lept tesseract 2>/dev/null || true)"
  [ -n "$cgo_cppflags" ] && export CGO_CPPFLAGS="$cgo_cppflags"
  [ -n "$cgo_ldflags" ] && export CGO_LDFLAGS="$cgo_ldflags"
fi
export GOTOOLCHAIN=local
# .NET tools
export PATH="$HOME/.dotnet/tools:$PATH"

# source ~/.zshrc

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
fi
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
# eval "$(mise activate zsh)"
export PATH="$(go env GOPATH)/bin:$PATH"
export NODE_OPTIONS="--max-old-space-size=8096"

# git-prompt
[ -f "$HOME/git-prompt.zsh" ] && source "$HOME/git-prompt.zsh"
# autosuggestions
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# syntax-highlighting
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

set -o vi

# Don't store redundant commands (like `ls` or `cd`)
# History Size (Balanced for Performance)
HISTSIZE=50000            # Commands stored in memory
SAVEHIST=50000            # Commands saved to file
HISTFILE=~/.zsh_history   # Location of the history file

# History Behavior Optimizations
setopt HIST_IGNORE_DUPS         # Ignore duplicate commands
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicates, keep latest
setopt HIST_REDUCE_BLANKS        # Trim unnecessary spaces before saving
setopt HIST_EXPIRE_DUPS_FIRST    # Remove oldest duplicate first when trimming
setopt HIST_SAVE_NO_DUPS         # Don't save duplicate commands in history
setopt NO_NOMATCH                # Keep unmatched globs literal (enables ?? command)

# History Performance Tweaks
setopt APPEND_HISTORY            # Append commands to history file, not overwrite
setopt INC_APPEND_HISTORY         # Write new commands immediately (no full reload)
setopt HIST_FCNTL_LOCK            # Prevent corruption when multiple shells write
setopt HIST_VERIFY                # Show command before running on history expansion

# history-substring-search
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/opt/zsh-history-substring-search/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]; then
  source "$HOMEBREW_PREFIX/opt/zsh-history-substring-search/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
elif [ -f /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

autoload -Uz compinit && compinit

export PATH="$HOME/.bun/bin:$PATH"
# Add phpenv to PATH for PHP version management
# export PATH="$HOME/.phpenv/bin:$PATH"

# export PHPVM_DIR="$HOME/.phpvm"
 
# [nvm] will replace with mise
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519_github
    ssh-add ~/.ssh/id_rsa_git_arisjirat
    ssh-add ~/.ssh/id_github_bfi
fi

# [usr/local/bin]
export PATH="/usr/local/bin:$PATH"
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig
export CGO_CFLAGS_ALLOW="-I"

export FVM_HOME="$HOME/fvm"
export PATH="$FVM_HOME/default/bin:$PATH"
 
# [flutter]
export PATH="$HOME/fvm/default/bin:$PATH"
if [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
elif [ -d "$HOME/Android/Sdk" ]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
fi
if [ -n "${ANDROID_HOME:-}" ]; then
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
  export PATH="$ANDROID_HOME/emulator:$PATH"
fi
if $_IS_MACOS; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/sbin:$PATH"
fi
export PATH="$HOME/.pub-cache/bin:$PATH"

# [java]
if [ -x /usr/libexec/java_home ]; then
  # macOS java_home utility
  java_home_21="$(/usr/libexec/java_home -v 21 2>/dev/null || true)"
  if [ -n "$java_home_21" ]; then
    export JAVA_HOME="$java_home_21"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
elif [ -d /usr/lib/jvm/java-21-openjdk-amd64 ]; then
  export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
  export PATH="$JAVA_HOME/bin:$PATH"
elif [ -d /usr/lib/jvm/java-21-openjdk ]; then
  export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# [mise]
export PATH="$HOME/.local/bin:$PATH"

# [composer]
export PATH="$HOME/.composer/vendor/bin:$PATH"
#

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
## [dart][Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true
## [/Completion]


# [ZSH] config_restart_aliases
[ -f "$HOME/.config_restart_aliases" ] && source "$HOME/.config_restart_aliases"
# [ZSH] fs_aliases
[ -f "$HOME/.fs_aliases" ] && source "$HOME/.fs_aliases"
# [ZSH] functions
[ -f "$HOME/.functions" ] && source "$HOME/.functions"
# [ZSH] git_aliases
[ -f "$HOME/.git_aliases" ] && source "$HOME/.git_aliases"
# [ZSH] docker_aliases
[ -f "$HOME/.docker_aliases" ] && source "$HOME/.docker_aliases"
# [ZSH] blue_dev
[ -f "$HOME/.blue_dev" ] && source "$HOME/.blue_dev"

# [ZSH] arduino
[ -f "$HOME/.arduino-cli-completion" ] && source "$HOME/.arduino-cli-completion"

if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

## [secrets]
[ -f ~/.secrets ] && source ~/.secrets


export GOPRIVATE=github.com/bfi-finance


if $_IS_MACOS; then
  export CATALINA_HOME="/opt/homebrew/opt/tomcat/libexec"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export PATH="$JAVA_HOME/bin:$PATH"

export PHPVM_DIR="$HOME/.phpvm"
export PATH="$PHPVM_DIR/bin:$PATH"




# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# [ZSH] lora
[ -f "$HOME/.lora" ] && source "$HOME/.lora"

# [ZSH] supertest — LORA E2E engine (sut, sutcd, sut-tmux)
[ -f "$HOME/.supertest" ] && source "$HOME/.supertest"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# LORA workspace alias
alias lora-workspace='nvim "/Users/mac-098183/work/lora/lora-workspace/lora.code-workspace"'

# LORA worktree orchestrator
alias lw='/Users/mac-098183/work/lora/lora-workspace/scripts/worktree.sh'
lwcd() { local d; d=$('/Users/mac-098183/work/lora/lora-workspace/scripts/worktree.sh' cd "$@") && cd "$d"; }

# LORA MQ sender
alias mq-send='/Users/mac-098183/work/lora/lora-workspace/scripts/mq-send.sh'

# [ZSH] sleep control (lid-close override for background agents)
lock() {
  local batt_pct reply
  batt_pct=$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%')

  if [[ -n "$batt_pct" && "$batt_pct" -lt 20 ]]; then
    echo "⚠️  Baterai di bawah 20% (${batt_pct}%). disablesleep bisa nahan mekanisme emergency-sleep macOS juga — resiko hard shutdown kalau baterai habis di tengah jalan."
    read "reply?Tetap lanjut dalam force mode? (yes/N): "
    if [[ "${reply:l}" != "yes" ]]; then
      echo "❌ Dibatalkan."
      return 1
    fi
    echo "⚡ Force mode diaktifkan pada baterai ${batt_pct}%."
  fi

  echo "🔒 Preventing sleep (lid-close sleep disabled) — safe to close the lid while an agent runs."
  sudo pmset -a disablesleep 1
  osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
}

hard() {
  local batt_pct reply
  batt_pct=$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%')

  if [[ -n "$batt_pct" && "$batt_pct" -lt 20 ]]; then
    echo "⚠️  Baterai di bawah 20% (${batt_pct}%). HARD mode juga mematikan displaysleep/disksleep/standby — resiko hard shutdown kalau baterai habis di tengah jalan, tanpa charger."
    read "reply?Tetap lanjut dalam hard mode? (yes/N): "
    if [[ "${reply:l}" != "yes" ]]; then
      echo "❌ Dibatalkan."
      return 1
    fi
    echo "⚡ Hard mode dipaksa aktif pada baterai ${batt_pct}%."
  fi

  echo "🔥 HARD mode: semua bentuk sleep/standby (display, disk, sistem) dimatikan di semua sumber daya — termasuk tanpa charger. Layar TIDAK dikunci."
  sudo pmset -a disablesleep 1 sleep 0 displaysleep 0 disksleep 0 standby 0
  echo "✅ Hard mode aktif — mesin tidak akan mati sama sekali sampai kamu jalankan 'normal'."
}

normal() {
  echo "💤 Restoring normal sleep behavior..."
  sudo pmset -a disablesleep 0 sleep 1 displaysleep 2 disksleep 10 standby 1
  pkill -x caffeinate 2>/dev/null
  if ioreg -r -k AppleClamshellState -d 4 | grep -q '"AppleClamshellState" = Yes'; then
    echo "Lid is closed but system is still awake — forcing sleep now."
    pmset sleepnow
  fi
  echo "✅ Normal sleep behavior restored."
}
