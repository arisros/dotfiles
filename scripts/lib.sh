# Shared helpers for install.sh and bootstrap scripts.
# Sourced — does not run anything on its own.

# ---- logging --------------------------------------------------------------
log()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$*" >&2; }
err()  { printf "\033[1;31m==>\033[0m %s\n" "$*" >&2; }

# ---- has_cmd: portable "command exists" check ---------------------------
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---- stow_module name [target] ------------------------------------------
# Stows a module dir into a target. Default target is $HOME/.config/<name>.
# Pass a second arg to override (e.g. "$HOME" for zsh/git/vim).
# Uses --restow so re-running install.sh doesn't error on existing links.
stow_module() {
    local module="$1"
    local default_target="$HOME/.config/$(basename "$module")"
    local target="${2:-$default_target}"

    if [ ! -d "$DOTFILES_DIR/$module" ]; then
        warn "stow: module '$module' not found at $DOTFILES_DIR/$module — skipping"
        return 0
    fi

    mkdir -p "$target"
    log "stow $module → $target"
    (cd "$DOTFILES_DIR" && stow --restow --target="$target" "$module")
}

# ---- bootstrap_tpm: install Tmux Plugin Manager + plugins ---------------
bootstrap_tpm() {
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$tpm_dir" ]; then
        log "Cloning TPM into $tpm_dir"
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi
    if [ -x "$tpm_dir/bin/install_plugins" ]; then
        log "Installing tmux plugins via TPM"
        "$tpm_dir/bin/install_plugins" || warn "TPM install_plugins exited non-zero"
    fi
}

# ---- install_fonts: copy nerd fonts to the OS-native font dir -----------
install_fonts() {
    local src="$DOTFILES_DIR/fonts"
    local dest
    case "$(uname -s)" in
        Darwin) dest="$HOME/Library/Fonts" ;;
        Linux)  dest="$HOME/.local/share/fonts" ;;
        *)      warn "install_fonts: unsupported OS"; return 0 ;;
    esac
    [ -d "$src" ] || { warn "install_fonts: $src not found — skipping"; return 0; }
    mkdir -p "$dest"
    log "Installing fonts from $src → $dest"
    # Use cp -n to skip files that already exist; fonts are large and rarely change.
    find "$src" -maxdepth 2 -type f \( -name '*.ttf' -o -name '*.otf' \) \
        -exec cp -n {} "$dest/" \;
    if [ "$(uname -s)" = "Linux" ] && has_cmd fc-cache; then
        log "Refreshing font cache"
        fc-cache -f "$dest" >/dev/null || true
    fi
}
