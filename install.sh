#!/bin/bash
# Install Xcode Command Line Tools
# xcode-select --install
#
# # Install Homebrew
# curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
#
# # Install Stow
# brew install stow git


mkdir -p ~/.config/aerospace
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/nvim
mkdir -p ~/.config/borders
mkdir -p ~/.config/sketchybar
mkdir -p ~/.config/tmux
mkdir -p ~/.config/ghostty
mkdir -p ~/.ssh
mkdir -p ~/.config/mise
mkdir -p ~/.config/nix

stow -t ~/.config/aerospace aerospace
stow -t ~/.config/alacritty alacritty
stow -t ~/.config/nvim nvim
stow -t ~/.config/borders borders
stow -t ~/.config/sketchybar sketchybar
stow -t ~/.config/tmux tmux
stow -t ~/.config/ghostty ghostty
stow -t ~/.ssh ssh
stow -t ~/.config/mise mise
stow -t ~ git
stow -t ~ vim
stow -t ~ zsh
stow -t ~/.config/nix nix

echo "Dotfiles successfully stowed!"

# Install Homebrew packages
# brew bundle --file=__scripts__/Brewfile

# run __scripts__
# ./__scripts__/install_version_manager.sh
# ./__scripts__/install_zsh_plugins.sh

# ./__macos__/defaults.sh

# Restore Brew
# brew bundle --file=Brewfile


# Restore defaults macos
# // restore not tested
# defaults import ~/macos-defaults-backup.plist
# // backup
# defaults read > ~/macos-defaults-backup.plist

# Load SSH Agent
# sudo launchctl load ~/Library/LaunchAgents/com.user.ssh-agent.plist

# Verify SSH keys
# ssh-add -l
