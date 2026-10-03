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

is_neovim_011() {
  if ! command -v nvim >/dev/null 2>&1; then
    return 1
  fi

  nvim_line="$(nvim --version 2>/dev/null | sed -n '1p')"
  case "$nvim_line" in
    # 0.12 breaks nvim-treesitter master, so a box with 0.12 still gets 0.11.
    "NVIM v0.11"*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

ensure_neovim_target() {
  if is_neovim_011; then
    return 0
  fi

  # Deliberately not `mise use -g neovim@...`. That writes a real
  # ~/.config/mise/config.toml, and this runs before the stow step, so it
  # leaves a plain file exactly where the repo's own mise package has to
  # link. Stow then refuses the package and the whole install exits 1.
  warn 'Neovim v0.11.x is required (0.12 breaks nvim-treesitter master). Installing...'
  case "$OS" in
    darwin)
      ensure_homebrew || return 1
      brew install neovim || brew upgrade neovim || true
      ;;
    linux)
      # Debian stable ships Neovim 0.7, which lazy.nvim rejects, so pull a
      # release build into ~/.local/bin instead of taking whatever apt has.
      if [ -x "$SCRIPT_DIR/__scripts__/install_nvim.sh" ]; then
        bash "$SCRIPT_DIR/__scripts__/install_nvim.sh" || warn 'Neovim release install failed.'
        export PATH="$HOME/.local/bin:$PATH"
      else
        apt_install neovim || true
      fi
      ;;
    *)
      warn "Unsupported OS for automatic Neovim install: $OS"
      return 1
      ;;
  esac

  if ! is_neovim_011; then
    warn 'Could not guarantee Neovim v0.11+ automatically. Install manually and rerun.'
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
  ensure_neovim_target || true
  ensure_optional_command lazygit lazygit lazygit || true
  ensure_optional_command rg ripgrep ripgrep || true
  ensure_optional_command jq jq jq || true
  ensure_optional_command gpg gnupg gnupg || true
  ensure_optional_command pass pass pass || true
  ensure_optional_command clang clang clang || true
  ensure_optional_command clang-format clang-format clang-format || true
  ensure_optional_command cmake cmake cmake || true
  ensure_optional_command ninja ninja-build ninja-build || true
  ensure_optional_command ccache ccache ccache || true
  ensure_optional_command cppcheck cppcheck cppcheck || true
  ensure_optional_command bear bear bear || true
fi

# Debian needs a wider net than the ensure_optional_command list above: yazi's
# previewers, the apt-shipped zsh plugins and clipboard tooling have no
# Homebrew-equivalent step on Linux.
if [ "$OS" = "linux" ] && [ "$SKIP_OPTIONAL_TOOLS" != "1" ]; then
  deb_list="$SCRIPT_DIR/__scripts__/debian-packages.txt"
  if [ -f "$deb_list" ]; then
    # One package per line. Strip inline comments (`pkg  # note`) and blanks,
    # otherwise the comment words reach apt as bogus package names and abort
    # the whole transaction.
    deb_pkgs="$(sed -E 's/#.*$//' "$deb_list" | grep -vE '^[[:space:]]*$' | tr '\n' ' ')"
    if [ -n "${deb_pkgs// /}" ]; then
      log 'Installing Debian packages...'
      # shellcheck disable=SC2086
      apt_install $deb_pkgs || warn 'Some apt packages failed; see above.'
    fi
  fi
fi

if [ "$SKIP_OPTIONAL_TOOLS" != "1" ] && [ -x "$SCRIPT_DIR/__scripts__/install_zsh_plugins.sh" ]; then
  log 'Installing zsh plugins...'
  bash "$SCRIPT_DIR/__scripts__/install_zsh_plugins.sh" || warn 'zsh plugin step had warnings.'
fi

# Local modules: created empty so the loaders have somewhere to look. What goes
# in it is deliberately outside this repo - see docs/plugins.md.
mkdir -p "$HOME/.config/dotfiles/modules"

# shellcheck source=__scripts__/stow-map.sh
source "$SCRIPT_DIR/__scripts__/stow-map.sh"

for dir in "${config_dirs[@]}"; do
  mkdir -p "$dir"
done

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

# LaunchAgent plists are templates: launchd does not expand $HOME, and a literal
# path would carry one machine's username into the repo.
render_launch_agents() {
  # launchd exists only on macOS; on Linux this would create a stray
  # ~/Library/LaunchAgents that nothing ever reads.
  [ "$OS" = "darwin" ] || return 0

  local dest="$HOME/Library/LaunchAgents"
  mkdir -p "$dest"
  local template plist domain
  domain="gui/$(id -u)"
  for template in "$SCRIPT_DIR"/*/com.user.*.plist; do
    [ -e "$template" ] || continue
    log "Rendering $(basename "$template") -> $dest"
    plist="$dest/$(basename "$template")"
    sed "s|__HOME__|$HOME|g" "$template" > "$plist"
    # launchd reads LaunchAgents only at login; reload so a fresh install works now.
    launchctl bootout "$domain" "$plist" 2>/dev/null || true
    launchctl bootstrap "$domain" "$plist" 2>/dev/null \
      || warn "Could not load $(basename "$plist"), it will load at next login"
  done
}

render_launch_agents
# The tracked CLAUDE.md imports this file. Create it empty so the import never
# dangles on a machine that has no private context to load.
touch "$HOME/.claude/context.local.md"
# settings.json is copied once, not linked: Claude Code and the tools that
# register hooks rewrite it in place, which would land machine state in the repo.
[ -e "$HOME/.claude/settings.json" ] || cp "$SCRIPT_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# Plugins: separate repos that link themselves into the local hooks. Each one is
# a symlink in the directory below, so this repo never names any of them. See
# docs/plugins.md.
plugin_dir="${DOTFILES_PLUGINS:-$HOME/.config/dotfiles/plugins}"
mkdir -p "$plugin_dir"
for plugin in "$plugin_dir"/*; do
  [ -x "$plugin/install.sh" ] || continue
  log "Installing plugin $(basename "$plugin")..."
  "$plugin/install.sh" || warn "Plugin $(basename "$plugin") reported problems."
done


ensure_tmux_bootstrap

if [ -x "$SCRIPT_DIR/__scripts__/install_git_hooks.sh" ]; then
  log 'Installing versioned git hooks...'
  "$SCRIPT_DIR/__scripts__/install_git_hooks.sh" || warn 'Could not install git hooks automatically.'
fi

if [ -x "$SCRIPT_DIR/__scripts__/sandi-setup.sh" ]; then
  "$SCRIPT_DIR/__scripts__/sandi-setup.sh" --quiet || true
fi

if [ "$OS" = "linux" ] && [ "$INSTALL_DEBIAN_BREW_EQUIV" = "1" ] && [ -x "$SCRIPT_DIR/__scripts__/install_debian_brew_equivalents.sh" ]; then
  log 'Installing Debian equivalents for Homebrew leaves...'
  debian_bridge_args=(--from-file "$SCRIPT_DIR/__scripts__/brew-leaves.txt")
  if [ "$APT_UPDATED" -eq 1 ]; then
    debian_bridge_args+=(--skip-update)
  fi
  "$SCRIPT_DIR/__scripts__/install_debian_brew_equivalents.sh" "${debian_bridge_args[@]}" || warn 'Debian package bridge encountered issues.'
fi

# yazi and joshuto are not in Debian stable; on macOS they come from the
# Brewfile, so this step is a no-op there.
if [ "$OS" = "linux" ] && [ "$SKIP_OPTIONAL_TOOLS" != "1" ] \
   && [ -x "$SCRIPT_DIR/__scripts__/install_rust_tools.sh" ]; then
  log 'Installing Rust CLI tools (yazi)...'
  bash "$SCRIPT_DIR/__scripts__/install_rust_tools.sh" || warn 'Rust CLI tool step had warnings.'
fi

if [ "$SKIP_MISE_INSTALL" = "1" ]; then
  warn 'Skipping mise install because DOTFILES_SKIP_MISE_INSTALL=1'
elif ensure_mise; then
  if [ -f "$HOME/.config/mise/config.toml" ]; then
    log 'Installing tools from mise config (this can take a while)...'
    mise install || warn 'mise install failed. You can rerun: mise install'
  fi
fi

if [ "${#stow_failures[@]}" -gt 0 ]; then
  warn 'Dotfiles setup finished with stow conflicts unresolved. See logs above and rerun after resolving.'
  exit 1
fi

log 'Dotfiles setup complete.'
