#!/usr/bin/env bash
# Cross-platform dotfiles installer (macOS + Debian/Ubuntu).
# Idempotent: safe to re-run. Skips work that's already done.
set -euo pipefail

# Resolve the dir this script lives in, regardless of how it was invoked.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

OS="$(uname -s)"
log "Installing dotfiles for $OS on $(uname -m)"

# ---- 1. OS-specific bootstrap (xcode/brew or apt) ------------------------
case "$OS" in
    Darwin)
        # shellcheck source=scripts/bootstrap-mac.sh
        source "$DOTFILES_DIR/scripts/bootstrap-mac.sh"
        ;;
    Linux)
        # shellcheck source=scripts/bootstrap-debian.sh
        source "$DOTFILES_DIR/scripts/bootstrap-debian.sh"
        ;;
    *)
        err "Unsupported OS: $OS"; exit 1
        ;;
esac

# ---- 2. Verify stow is now available -------------------------------------
if ! has_cmd stow; then
    err "GNU stow is required but not installed. Aborting."
    exit 1
fi

# ---- 3. Stow cross-platform modules --------------------------------------
# Most modules go under ~/.config/<name>; zsh/git/vim land directly in $HOME.
stow_module nvim
stow_module tmux
stow_module yazi
stow_module joshuto
stow_module alacritty
stow_module ghostty
stow_module mise
stow_module nix
stow_module ssh        "$HOME/.ssh"
stow_module zsh        "$HOME"
stow_module git        "$HOME"
stow_module vim        "$HOME"

# ---- 4. Stow macOS-only modules ------------------------------------------
if [ "$OS" = "Darwin" ]; then
    stow_module macos/aerospace        "$HOME/.config/aerospace"
    stow_module macos/borders          "$HOME/.config/borders"
    stow_module macos/sketchybar       "$HOME/.config/sketchybar"
    stow_module macos/ssh-launchagent  "$HOME"
    # Karabiner rewrites karabiner.json on every change, so that file can never
    # be a symlink. assets/complex_modifications/ is read-only to Karabiner —
    # safe to stow. Rules still have to be enabled once in the GUI.
    stow_module macos/karabiner        "$HOME/.config/karabiner/assets/complex_modifications"
fi

# ---- 5. Bootstrap plugins + tools ----------------------------------------
# Everything below is heavy/network-dependent (toolchain installs, font copy).
# Set DOTFILES_MINIMAL=1 to stop here with just the configs symlinked — used by
# CI and handy when you only want dotfiles linked without the full toolchain.
if [ "${DOTFILES_MINIMAL:-0}" = "1" ]; then
    log "DOTFILES_MINIMAL=1 — configs stowed; skipping toolchain + fonts. Done."
    exit 0
fi

log "Installing latest Neovim (apt/brew versions may be too old for lazy.nvim)"
bash "$DOTFILES_DIR/scripts/install_nvim.sh" || warn "nvim install had warnings"

bootstrap_tpm
log "Running scripts/install_zsh_plugins.sh"
bash "$DOTFILES_DIR/scripts/install_zsh_plugins.sh" || warn "zsh plugins step had warnings"

if has_cmd mise; then
    # Trust the repo's mise config so auto-discovery doesn't refuse it.
    # (mise trust state is per-user, can't live in the repo.)
    log "Trusting mise configs in $DOTFILES_DIR"
    mise trust "$DOTFILES_DIR" >/dev/null 2>&1 || true
    mise trust "$DOTFILES_DIR/mise/config.toml" >/dev/null 2>&1 || true

    log "mise install (materializing runtimes from mise/config.toml)"
    mise install || warn "mise install had warnings"
else
    warn "mise not on PATH yet — re-run install.sh after a new shell to pick up runtimes"
fi

# Rust-based CLI tools (yazi, joshuto). On macOS these come from Brewfile;
# on Linux they're cargo-installed because Debian doesn't package them.
if [ "$OS" = "Linux" ]; then
    log "Installing Rust CLI tools (yazi, joshuto) via cargo"
    bash "$DOTFILES_DIR/scripts/install_rust_tools.sh" || warn "Rust tools install had warnings"
fi

install_fonts

# ---- 6. Done -------------------------------------------------------------
log "Done."
log "Next steps:"
log "  1. Start a new shell (or 'exec zsh') to load the new config."
log "  2. (macOS only, optional) bash $DOTFILES_DIR/macos/scripts/macos-defaults.sh"
log "  3. (macOS only, optional) sudo launchctl load ~/Library/LaunchAgents/com.user.ssh-agent.plist"
