# shellcheck shell=bash
# Debian/Ubuntu prereqs. Sourced by install.sh when uname -s = Linux.

if ! has_cmd apt-get; then
    err "Only apt-based Linux distros are supported. Skipping system packages."
    return 0
fi

# Use sudo only when not already root.
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

log "apt update"
$SUDO apt-get update -y

if [ -f "$DOTFILES_DIR/packages/debian.txt" ]; then
    # Strip comments and blanks, then install.
    pkgs=$(grep -vE '^\s*(#|$)' "$DOTFILES_DIR/packages/debian.txt" | tr '\n' ' ')
    log "Installing apt packages: $pkgs"
    # shellcheck disable=SC2086
    $SUDO apt-get install -y $pkgs || warn "apt install had failures (check above)"
else
    log "No packages/debian.txt found, installing minimal set"
    $SUDO apt-get install -y zsh stow git curl ca-certificates build-essential
fi
