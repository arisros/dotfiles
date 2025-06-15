export CONFIG_DIR="$HOME/.config/sketchybar"
export ITEM_DIR="$CONFIG_DIR/items"
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(~/.local/bin/mise activate zsh)"

# git-prompt
source ~/git-prompt.zsh
# autosuggestions
source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# syntax-highlighting
source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

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

# History Performance Tweaks
setopt APPEND_HISTORY            # Append commands to history file, not overwrite
setopt INC_APPEND_HISTORY         # Write new commands immediately (no full reload)
setopt HIST_FCNTL_LOCK            # Prevent corruption when multiple shells write
setopt HIST_VERIFY                # Show command before running on history expansion

# history-substring-search
source "$HOMEBREW_PREFIX/opt/zsh-history-substring-search/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

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
 
# [flutter]
export PATH="$HOME/fvm/default/bin:$PATH"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"

# [java]
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH=$JAVA_HOME/bin:$PATH

# [mise]
export PATH="$HOME/.local/bin:$PATH"

# [composer]
export PATH="$HOME/.composer/vendor/bin:$PATH"
#

eval "$(~/.local/bin/mise activate zsh)"
## [dart][Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/arisjirat/.dart-cli-completion/zsh-config.zsh ]] && . /Users/arisjirat/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]


# [ZSH] config_restart_aliases
source ~/.config_restart_aliases
# [ZSH] fs_aliases
source ~/.fs_aliases
# [ZSH] functions
source ~/.functions
# [ZSH] git_aliases
source ~/.git_aliases
# [ZSH] docker_aliases
source ~/.docker_aliases
# [ZSH] blue_dev
source ~/.blue_dev

# [ZSH] arduino
source ~/.arduino-cli-completion

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/justtest/.dart-cli-completion/zsh-config.zsh ]] && . /Users/justtest/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

## [secrets]
[ -f ~/.secrets ] && source ~/.secrets


export GOPRIVATE=github.com/bfi-finance


export CATALINA_HOME="/opt/homebrew/opt/tomcat/libexec"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export PATH="$JAVA_HOME/bin:$PATH"

export PHPVM_DIR="/Users/justtest/.phpvm"
export PATH="$PHPVM_DIR/bin:$PATH"
[ -s "$PHPVM_DIR/phpvm.sh" ] && . "$PHPVM_DIR/phpvm.sh"


#c[mysql]
export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"

export PHPVM_DIR="~/.phpvm"
export PATH="$PHPVM_DIR/bin:$PATH"
[ -s "$PHPVM_DIR/phpvm.sh" ] && . "$PHPVM_DIR/phpvm.sh"


