export CONFIG_DIR="$HOME/.config/sketchybar"
export ITEM_DIR="$CONFIG_DIR/items"
eval "$(/opt/homebrew/bin/brew shellenv)"

# git-prompt
source ~/git-prompt.zsh
# autosuggestions
source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# syntax-highlighting
source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# PROMPT='%n@%m %~ $(git_prompt_info) $ '
setopt HIST_IGNORE_DUPS

set -o vi

# Don't store redundant commands (like `ls` or `cd`)
# Increase history size
HISTSIZE=100000            # Number of commands stored in memory
SAVEHIST=100000            # Number of commands saved to file
HISTFILE=~/.zsh_history    # Location of the history file

# Enhance history behavior
setopt HIST_IGNORE_DUPS    # Ignore duplicate commands
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate entries, keeping latest
setopt HIST_REDUCE_BLANKS  # Remove unnecessary spaces before saving
setopt HIST_SAVE_NO_DUPS   # Don't save duplicate commands in history
setopt HIST_EXPIRE_DUPS_FIRST # Remove oldest duplicate first when trimming
setopt SHARE_HISTORY       # Share history across multiple Zsh sessions
setopt HIST_REDUCE_BLANKS


export PATH="$HOME/.bun/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519_github
    ssh-add ~/.ssh/id_rsa_git_arisjirat
    ssh-add ~/.ssh/id_github_bfi
fi

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


## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/justtest/.dart-cli-completion/zsh-config.zsh ]] && . /Users/justtest/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

