#!/usr/bin/env bash
# Install zsh plugins that aren't covered by the system package manager.
# - macOS: install via brew (autosuggestions, syntax-highlighting, history-substring-search, fzf)
# - Debian: autosuggestions + syntax-highlighting come from apt;
#           history-substring-search isn't packaged → vendor under ~/.zsh-plugins/
set -euo pipefail

OS="$(uname -s)"

install_mac() {
    echo "==> Installing Zsh plugins on macOS via brew"
    brew install zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search fzf
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc || true
}

install_linux() {
    echo "==> Vendoring zsh-history-substring-search (apt doesn't ship it)"
    local dest="$HOME/.zsh-plugins/zsh-history-substring-search"
    if [ ! -d "$dest" ]; then
        mkdir -p "$(dirname "$dest")"
        git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$dest"
    else
        echo "    already present at $dest"
    fi
    # zsh-autosuggestions, zsh-syntax-highlighting, fzf come from apt
    # (see packages/debian.txt). Nothing else to do here.
}

case "$OS" in
    Darwin) install_mac ;;
    Linux)  install_linux ;;
    *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

echo "==> Zsh plugins ready"
