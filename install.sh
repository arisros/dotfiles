#!/bin/bash

mkdir -p ~/.config/aerospace
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/nvim
mkdir -p ~/.config/borders
mkdir -p ~/.config/sketchybar
mkdir -p ~/.config/tmux
mkdir -p ~/.config/ghostty
mkdir -p ~/.ssh

stow -t ~/.config/aerospace aerospace
stow -t ~/.config/alacritty alacritty
stow -t ~/.config/nvim nvim
stow -t ~/.config/borders borders
stow -t ~/.config/sketchybar sketchybar
stow -t ~/.config/tmux tmux
stow -t ~/.config/ghostty ghostty
stow -t ~/.ssh ssh
stow -t ~ git
stow -t ~ vim
stow -t ~ zsh

echo "Dotfiles successfully stowed!"

# run __scripts__

./__scripts__/install_version_manager.sh
./__scripts__/install_zsh_plugins.sh


# Load SSH Agent
# sudo launchctl load ~/Library/LaunchAgents/com.user.ssh-agent.plist

# Verify SSH keys
# ssh-add -l
