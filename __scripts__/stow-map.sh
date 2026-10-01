# shellcheck shell=bash
# Sourced by install.sh and dots-sync.sh; expects OS (darwin|linux) to be set.

config_dirs=(
  "$HOME/.config/alacritty"
  "$HOME/.config/nvim"
  "$HOME/.config/tmux"
  "$HOME/.claude"
  "$HOME/.config/ghostty"
  "$HOME/.config/opencode"
  "$HOME/.ssh"
  "$HOME/.config/mise"
  "$HOME/.config/nix"
  "$HOME/.config/yazi"
  "$HOME/.config/htop"
)

stow_pairs=(
  "$HOME/.config/alacritty:alacritty"
  "$HOME/.config/nvim:nvim"
  "$HOME/.config/tmux:tmux"
  "$HOME/.claude:claude"
  "$HOME/.config/ghostty:ghostty"
  "$HOME:opencode"
  "$HOME/.ssh:ssh"
  "$HOME/.config/mise:mise"
  "$HOME/.config/yazi:yazi"
  "$HOME/.config/htop:htop"
  "$HOME:git"
  "$HOME:vim"
  "$HOME:zsh"
  "$HOME/.config/nix:nix"
  "$HOME:lynx"
)

# aerospace, borders and sketchybar are macOS window-manager tooling; creating
# and stowing them on Linux leaves dead config nothing will ever read.
if [ "$OS" = "darwin" ]; then
  config_dirs+=(
    "$HOME/.config/aerospace"
    "$HOME/.config/borders"
    "$HOME/.config/sketchybar"
  )
  stow_pairs+=(
    "$HOME/.config/aerospace:aerospace"
    "$HOME/.config/borders:borders"
    "$HOME/.config/sketchybar:sketchybar"
  )
fi
