# shellcheck shell=bash
# macOS prereqs. Sourced by install.sh when uname -s = Darwin.

if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools (interactive prompt may appear)"
    xcode-select --install || true
fi

if ! has_cmd brew; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make brew available in this shell.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

log "Installing base prerequisites via brew"
brew install stow git curl

if [ -f "$DOTFILES_DIR/packages/Brewfile" ]; then
    log "Running brew bundle"
    brew bundle --file="$DOTFILES_DIR/packages/Brewfile" || warn "brew bundle had failures (check above)"
fi
