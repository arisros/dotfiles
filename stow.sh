#!/bin/bash

mkdir -p ~/.config/aerospace
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/nvim
mkdir -p ~/.config/borders
mkdir -p ~/.config/sketchybar
mkdir -p ~/.config/tmux
mkdir -p ~/.config/ghostty

stow -t ~/.config/aerospace aerospace
stow -t ~/.config/alacritty alacritty
stow -t ~/.config/nvim nvim
stow -t ~/.config/borders borders
stow -t ~/.config/sketchybar sketchybar
stow -t ~/.config/tmux tmux
stow -t ~/.config/ghostty ghostty
stow -t ~ vim
stow -t ~ zsh

echo "Dotfiles successfully stowed!"
