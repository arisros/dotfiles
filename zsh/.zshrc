export CONFIG_DIR="$HOME/.config/sketchybar"
export ITEM_DIR="$CONFIG_DIR/items"

PROMPT='%n@%m %~ $ '

setopt HIST_IGNORE_DUPS

# Don't store redundant commands (like `ls` or `cd`)
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

[[ -f ~/.git_aliases ]] && source ~/.git_aliases
[[ -f ~/.config_restart_aliases ]] && source ~/.config_restart_aliases
[[ -f ~/.fs_aliases ]] && source ~/.fs_aliases

if [[ ! -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || ! -f /opt/homebrew/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh || ! $(command -v fzf) ]]; then
    ~/install_zsh_plugins.sh
	source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

fi



