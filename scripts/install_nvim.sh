#!/usr/bin/env bash
# Install a recent Neovim into ~/.local/bin (and ~/.local/share/nvim-current).
# Debian's apt ships Neovim 0.7 which is too old for lazy.nvim (needs ≥0.8).
# This script grabs the latest stable tarball from the Neovim GitHub releases
# and shadows the apt version because ~/.local/bin comes first on PATH.
set -euo pipefail

DEST_BIN="$HOME/.local/bin"
DEST_DIR="$HOME/.local/share/nvim-current"
mkdir -p "$DEST_BIN" "$(dirname "$DEST_DIR")"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS-$ARCH" in
    Linux-x86_64)  asset="nvim-linux-x86_64.tar.gz" ;;
    Linux-aarch64) asset="nvim-linux-arm64.tar.gz" ;;
    Darwin-arm64)  asset="nvim-macos-arm64.tar.gz" ;;
    Darwin-x86_64) asset="nvim-macos-x86_64.tar.gz" ;;
    *) echo "Unsupported $OS-$ARCH" >&2; exit 1 ;;
esac

url="https://github.com/neovim/neovim/releases/latest/download/$asset"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "==> Downloading $url"
curl -fsSL -o "$tmp/nvim.tar.gz" "$url"

echo "==> Extracting to $DEST_DIR"
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
tar -xzf "$tmp/nvim.tar.gz" -C "$DEST_DIR" --strip-components=1

# Symlink the binary into a dir that's already on PATH.
ln -sf "$DEST_DIR/bin/nvim" "$DEST_BIN/nvim"

echo "==> Installed: $("$DEST_BIN/nvim" --version | head -1)"
echo "    (ensure ~/.local/bin is early on PATH; .zshrc already does this)"
