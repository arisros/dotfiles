#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
APT_UPDATED=0
SKIP_MISE_INSTALL="${DOTFILES_SKIP_MISE_INSTALL:-0}"
SKIP_OPTIONAL_TOOLS="${DOTFILES_SKIP_OPTIONAL_TOOLS:-0}"
INSTALL_ZSH="${DOTFILES_INSTALL_ZSH:-1}"
INSTALL_DEBIAN_BREW_EQUIV="${DOTFILES_INSTALL_DEBIAN_BREW_EQUIV:-1}"
STOW_ADOPT="${DOTFILES_STOW_ADOPT:-1}"
INSTALL_OPENCODE="${DOTFILES_INSTALL_OPENCODE:-1}"
INSTALL_OH_MY_OPENCODE="${DOTFILES_INSTALL_OH_MY_OPENCODE:-1}"
OH_MY_OPENCODE_FLAGS="${DOTFILES_OH_MY_OPENCODE_FLAGS:---claude=no --openai=no --gemini=no --copilot=no --opencode-zen=no --zai-coding-plan=no}"

log() {
  printf '[install] %s\n' "$*"
}

warn() {
  printf '[install][warn] %s\n' "$*" >&2
}

run_with_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    if command -v sudo >/dev/null 2>&1; then
      sudo "$@"
    else
      warn "sudo is not installed. Re-run as root to execute: $*"
      return 1
    fi
  fi
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  warn 'Homebrew is missing. Installing Homebrew in non-interactive mode...'
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    warn 'Failed to set up Homebrew automatically.'
    return 1
  fi
}

apt_install() {
  if ! command -v apt-get >/dev/null 2>&1; then
    warn 'apt-get is not available on this Linux system.'
    return 1
  fi

  if [ "$APT_UPDATED" -eq 0 ]; then
    log 'Running apt-get update...'
    run_with_sudo apt-get update
    APT_UPDATED=1
  fi

  run_with_sudo apt-get install -y "$@"
}

ensure_command() {
  cmd="$1"
  mac_pkg="$2"
  deb_pkg="$3"

  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi

  warn "$cmd is missing. Attempting automatic install..."
  case "$OS" in
    darwin)
      ensure_homebrew || return 1
      brew install "$mac_pkg"
      ;;
    linux)
      apt_install "$deb_pkg"
      ;;
    *)
      warn "Unsupported OS for automatic installation: $OS"
      return 1
      ;;
  esac

  if ! command -v "$cmd" >/dev/null 2>&1; then
    warn "$cmd installation did not succeed automatically."
    return 1
  fi

  return 0
}

ensure_optional_command() {
  cmd="$1"
  mac_pkg="$2"
  deb_pkg="$3"

  if ! ensure_command "$cmd" "$mac_pkg" "$deb_pkg"; then
    warn "Optional command unavailable after install attempt: $cmd"
    return 1
  fi

  return 0
}

ensure_mise() {
  if command -v mise >/dev/null 2>&1; then
    return 0
  fi

  warn 'mise is missing. Attempting installation via https://mise.run ...'
  if ! command -v curl >/dev/null 2>&1; then
    warn 'curl is required to install mise.'
    return 1
  fi

  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"

  if ! command -v mise >/dev/null 2>&1; then
    warn 'mise installation failed. Continuing without automatic tool install.'
    return 1
  fi

  return 0
}

ensure_tmux_bootstrap() {
  xdg_tmux_conf="$HOME/.config/tmux/tmux.conf"
  legacy_tmux_conf="$HOME/.tmux.conf"
  tpm_dir="$HOME/.config/tmux/plugins/tpm"
  tpm_exec="$tpm_dir/tpm"
  install_plugins_exec="$tpm_dir/bin/install_plugins"

  if [ -f "$xdg_tmux_conf" ] && [ ! -e "$legacy_tmux_conf" ]; then
    ln -s "$xdg_tmux_conf" "$legacy_tmux_conf"
  fi

  if [ ! -x "$tpm_exec" ] && command -v git >/dev/null 2>&1; then
    mkdir -p "$HOME/.config/tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir" >/dev/null 2>&1 || true
  fi

  if [ -x "$install_plugins_exec" ] && command -v tmux >/dev/null 2>&1; then
    "$install_plugins_exec" >/dev/null 2>&1 || true
  fi
}

ensure_opencode_cli() {
  if command -v opencode >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn 'curl is required to install OpenCode.'
    return 1
  fi

  warn 'OpenCode is missing. Attempting install via https://opencode.ai/install ...'
  curl -fsSL https://opencode.ai/install | bash

  export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
  if ! command -v opencode >/dev/null 2>&1; then
    warn 'OpenCode installation failed. Install manually: curl -fsSL https://opencode.ai/install | bash'
    return 1
  fi

  return 0
}

install_oh_my_opencode() {
  if command -v bunx >/dev/null 2>&1; then
    installer=(bunx)
  elif command -v npx >/dev/null 2>&1; then
    installer=(npx)
  else
    warn 'oh-my-opencode installer requires bunx or npx. Install Bun/Node first, then rerun with DOTFILES_INSTALL_OH_MY_OPENCODE=1.'
    return 1
  fi

  if [ ! -f "$HOME/.config/opencode/opencode.json" ]; then
    warn 'OpenCode config not found at ~/.config/opencode/opencode.json. Run stow/install first.'
    return 1
  fi

  flags=()
  IFS=' ' read -r -a flags <<< "$OH_MY_OPENCODE_FLAGS"
  log "Installing oh-my-opencode with flags: $OH_MY_OPENCODE_FLAGS"
  "${installer[@]}" oh-my-opencode install --no-tui "${flags[@]}" || {
    warn 'oh-my-opencode installation failed. You can rerun manually with bunx/npx.'
    return 1
  }

  return 0
}

log "Detected OS: $OS"

ensure_command git git git || warn 'Please install git manually if this fails.'
ensure_command stow stow stow || {
  warn 'stow is required for linking dotfiles. Aborting.'
  exit 1
}
ensure_command curl curl curl || warn 'curl is recommended for bootstrap steps.'

if [ "$SKIP_OPTIONAL_TOOLS" = "1" ]; then
  warn 'Skipping optional tool installation because DOTFILES_SKIP_OPTIONAL_TOOLS=1'
else
  if [ "$INSTALL_ZSH" = "1" ]; then
    ensure_optional_command zsh zsh zsh || true
  fi
  ensure_optional_command tmux tmux tmux || true
  ensure_optional_command nvim neovim neovim || true
  ensure_optional_command rg ripgrep ripgrep || true
  ensure_optional_command jq jq jq || true
  ensure_optional_command gpg gnupg gnupg || true
  ensure_optional_command pass pass pass || true
fi

config_dirs=(
  "$HOME/.config/aerospace"
  "$HOME/.config/alacritty"
  "$HOME/.config/nvim"
  "$HOME/.config/borders"
  "$HOME/.config/sketchybar"
  "$HOME/.config/tmux"
  "$HOME/.config/ghostty"
  "$HOME/.config/opencode"
  "$HOME/.ssh"
  "$HOME/.config/mise"
  "$HOME/.config/nix"
  "$HOME/.config/yazi"
)

for dir in "${config_dirs[@]}"; do
  mkdir -p "$dir"
done

stow_pairs=(
  "$HOME/.config/aerospace:aerospace"
  "$HOME/.config/alacritty:alacritty"
  "$HOME/.config/nvim:nvim"
  "$HOME/.config/borders:borders"
  "$HOME/.config/sketchybar:sketchybar"
  "$HOME/.config/tmux:tmux"
  "$HOME/.config/ghostty:ghostty"
  "$HOME:opencode"
  "$HOME/.ssh:ssh"
  "$HOME/.config/mise:mise"
  "$HOME/.config/yazi:yazi"
  "$HOME:git"
  "$HOME:vim"
  "$HOME:zsh"
  "$HOME/.config/nix:nix"
  "$HOME:lynx"
)

stow_failures=()

for pair in "${stow_pairs[@]}"; do
  target="${pair%%:*}"
  pkg="${pair#*:}"
  if [ ! -e "$SCRIPT_DIR/$pkg" ]; then
    warn "Skipping missing package: $pkg"
    continue
  fi
  log "Stowing $pkg -> $target"
  stow_args=(-R -t "$target")
  if [ "$STOW_ADOPT" = "1" ]; then
    stow_args=(--adopt "${stow_args[@]}")
  fi

  stow_output=''
  if ! stow_output="$(stow "${stow_args[@]}" "$pkg" 2>&1)"; then
    warn "Stow failed for $pkg -> $target"
    printf '%s\n' "$stow_output" >&2
    stow_failures+=("$pkg -> $target")
    continue
  fi

  if [ -n "$stow_output" ]; then
    printf '%s\n' "$stow_output"
  fi
done

if [ "${#stow_failures[@]}" -gt 0 ]; then
  warn 'One or more stow operations failed due to existing files/conflicts:'
  for failure in "${stow_failures[@]}"; do
    warn "  - $failure"
  done
  if [ "$STOW_ADOPT" != "1" ]; then
    warn 'Re-run with DOTFILES_STOW_ADOPT=1 to adopt existing files into their matching stow package.'
  fi
  warn 'Or move/remove conflicting files manually and re-run ./install.sh'
fi

ensure_tmux_bootstrap

if [ -x "$SCRIPT_DIR/__scripts__/install_git_hooks.sh" ]; then
  log 'Installing versioned git hooks...'
  "$SCRIPT_DIR/__scripts__/install_git_hooks.sh" || warn 'Could not install git hooks automatically.'
fi

if [ -f "$SCRIPT_DIR/zsh/.secrets.example" ] && [ ! -f "$HOME/.secrets" ]; then
  cp "$SCRIPT_DIR/zsh/.secrets.example" "$HOME/.secrets"
  chmod 600 "$HOME/.secrets"
  warn 'Created ~/.secrets from template. Fill values or run __scripts__/restore_credentials.sh'
fi

if [ -x "$SCRIPT_DIR/__scripts__/restore_credentials.sh" ]; then
  "$SCRIPT_DIR/__scripts__/restore_credentials.sh" --quiet || true
fi

if [ "$OS" = "linux" ] && [ "$INSTALL_DEBIAN_BREW_EQUIV" = "1" ] && [ -x "$SCRIPT_DIR/__scripts__/install_debian_brew_equivalents.sh" ]; then
  log 'Installing Debian equivalents for Homebrew leaves...'
  debian_bridge_args=(--from-file "$SCRIPT_DIR/__scripts__/brew-leaves.txt")
  if [ "$APT_UPDATED" -eq 1 ]; then
    debian_bridge_args+=(--skip-update)
  fi
  "$SCRIPT_DIR/__scripts__/install_debian_brew_equivalents.sh" "${debian_bridge_args[@]}" || warn 'Debian package bridge encountered issues.'
fi

if [ "$SKIP_MISE_INSTALL" = "1" ]; then
  warn 'Skipping mise install because DOTFILES_SKIP_MISE_INSTALL=1'
elif ensure_mise; then
  if [ -f "$HOME/.config/mise/config.toml" ]; then
    log 'Installing tools from mise config (this can take a while)...'
    mise install || warn 'mise install failed. You can rerun: mise install'
  fi
fi

if [ "$INSTALL_OPENCODE" = "1" ]; then
  ensure_opencode_cli || warn 'OpenCode install step encountered issues.'
fi

if [ "$INSTALL_OH_MY_OPENCODE" = "1" ]; then
  ensure_opencode_cli || true
  install_oh_my_opencode || warn 'oh-my-opencode install step encountered issues.'
fi

if [ "${#stow_failures[@]}" -gt 0 ]; then
  warn 'Dotfiles setup finished with stow conflicts unresolved. See logs above and rerun after resolving.'
  exit 1
fi

log 'Dotfiles setup complete.'
