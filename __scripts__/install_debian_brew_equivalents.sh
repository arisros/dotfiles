#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INPUT_FILE=""
INCLUDE_GUI=0
DRY_RUN=0
SKIP_UPDATE=0

usage() {
  cat <<'EOF'
Usage: ./__scripts__/install_debian_brew_equivalents.sh [options]

Options:
  --from-file <path>  Use a brew leaves list file (default: auto detect)
  --include-gui       Include GUI/media formulas (default: skip)
  --dry-run           Do not install, only print plan
  --skip-update       Skip apt-get update
  -h, --help          Show help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --from-file)
      shift
      INPUT_FILE="${1:-}"
      [ -n "$INPUT_FILE" ] || { printf 'Missing value for --from-file\n' >&2; exit 1; }
      ;;
    --include-gui)
      INCLUDE_GUI=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --skip-update)
      SKIP_UPDATE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ "$(uname -s)" != "Linux" ]; then
  printf 'install_debian_brew_equivalents: Linux only\n' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf 'install_debian_brew_equivalents: apt-get not found\n' >&2
  exit 1
fi

run_with_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    printf 'Need root or sudo for apt operations\n' >&2
    exit 1
  fi
}

normalize_formula() {
  local formula="$1"
  formula="${formula##*/}"
  printf '%s\n' "$formula"
}

is_gui_formula() {
  case "$1" in
    borders|sketchybar|mpv)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

map_formula_to_apt() {
  case "$1" in
    beautysh) printf 'beautysh\n' ;;
    bettercap) printf 'bettercap\n' ;;
    browsh) printf 'browsh\n' ;;
    composer) printf 'composer\n' ;;
    cowsay) printf 'cowsay\n' ;;
    delve) printf 'golang-delve\n' ;;
    entr) printf 'entr\n' ;;
    ettercap) printf 'ettercap-text-only\n' ;;
    exiftool) printf 'libimage-exiftool-perl\n' ;;
    fd) printf 'fd-find\n' ;;
    fortune) printf 'fortune-mod\n' ;;
    fzf) printf 'fzf\n' ;;
    gh) printf 'gh\n' ;;
    git) printf 'git\n' ;;
    git-filter-repo) printf 'git-filter-repo\n' ;;
    git-secret) printf 'git-secret\n' ;;
    go) printf 'golang-go\n' ;;
    gobject-introspection) printf 'gobject-introspection\n' ;;
    htop) printf 'htop\n' ;;
    jdtls) printf 'eclipse-jdtls\n' ;;
    jq) printf 'jq\n' ;;
    lazygit) printf 'lazygit\n' ;;
    lcov) printf 'lcov\n' ;;
    lf) printf 'lf\n' ;;
    lftp) printf 'lftp\n' ;;
    libffi) printf 'libffi-dev\n' ;;
    libxslt) printf 'libxslt1-dev\n' ;;
    lynx) printf 'lynx\n' ;;
    mpv) printf 'mpv\n' ;;
    mycli) printf 'mycli\n' ;;
    mysql@8.0|mysql) printf 'default-mysql-client\n' ;;
    nats) printf 'nats-server\n' ;;
    neovim) printf 'neovim\n' ;;
    nmap) printf 'nmap\n' ;;
    nnn) printf 'nnn\n' ;;
    nushell) printf 'nushell\n' ;;
    pandoc) printf 'pandoc\n' ;;
    pass-otp) printf 'pass-extension-otp\n' ;;
    pipx) printf 'pipx\n' ;;
    pnpm) printf 'pnpm\n' ;;
    redis) printf 'redis-server\n' ;;
    resvg) printf 'resvg\n' ;;
    sevenzip) printf 'p7zip-full\n' ;;
    stow) printf 'stow\n' ;;
    tig) printf 'tig\n' ;;
    tmux) printf 'tmux\n' ;;
    tomcat) printf 'tomcat10\n' ;;
    urlview) printf 'urlview\n' ;;
    vips) printf 'libvips-tools\n' ;;
    w3m) printf 'w3m\n' ;;
    wireguard-tools) printf 'wireguard-tools\n' ;;
    zbar) printf 'zbar-tools\n' ;;
    zoxide) printf 'zoxide\n' ;;
    zsh-autosuggestions) printf 'zsh-autosuggestions\n' ;;
    zsh-history-substring-search) printf 'zsh-history-substring-search\n' ;;
    zsh-syntax-highlighting) printf 'zsh-syntax-highlighting\n' ;;
    zsh) printf 'zsh\n' ;;
    *) printf '' ;;
  esac
}

fallback_hint() {
  case "$1" in
    git-secrets) printf 'manual: https://github.com/awslabs/git-secrets\n' ;;
    chatgpt-cli) printf 'manual: npm/pipx install for chatgpt-cli\n' ;;
    jira-cli) printf 'manual: use Atlassian jira-cli installer\n' ;;
    jiratui) printf 'manual: build from source (Rust/Go depending on tool)\n' ;;
    joshuto|viu|yazi) printf 'manual: cargo install %s\n' "$1" ;;
    lazysql) printf 'manual: download release binary\n' ;;
    fvm) printf 'manual: curl -fsSL https://fvm.app/install.sh | bash\n' ;;
    mockery) printf 'manual: go install github.com/vektra/mockery/v2@latest\n' ;;
    ollama) printf 'manual: curl -fsSL https://ollama.com/install.sh | sh\n' ;;
    supabase) printf 'manual: https://github.com/supabase/cli/releases\n' ;;
    temporal) printf 'manual: https://docs.temporal.io/cli\n' ;;
    *) printf 'manual install required\n' ;;
  esac
}

read_formulas() {
  if [ -n "$INPUT_FILE" ]; then
    [ -f "$INPUT_FILE" ] || { printf 'Input file not found: %s\n' "$INPUT_FILE" >&2; exit 1; }
    cat "$INPUT_FILE"
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    brew leaves
    return
  fi

  if [ -f "$SCRIPT_DIR/brew-leaves.txt" ]; then
    cat "$SCRIPT_DIR/brew-leaves.txt"
    return
  fi

  printf 'No brew list source found. Use --from-file <brew-leaves.txt>\n' >&2
  exit 1
}

apt_packages=()
skipped_gui=()
unmapped=()
unavailable_apt=()

is_unique() {
  local value="$1"
  shift
  local item
  for item in "$@"; do
    [ "$item" = "$value" ] && return 1
  done
  return 0
}

while IFS= read -r raw_formula; do
  formula="$(printf '%s' "$raw_formula" | xargs)"
  [ -n "$formula" ] || continue
  case "$formula" in
    \#*) continue ;;
  esac

  if ! printf '%s' "$formula" | grep -Eq '^[A-Za-z0-9@._+/-]+$'; then
    continue
  fi

  normalized="$(normalize_formula "$formula")"

  if is_gui_formula "$normalized" && [ "$INCLUDE_GUI" -ne 1 ]; then
    if is_unique "$normalized" "${skipped_gui[@]}"; then
      skipped_gui+=("$normalized")
    fi
    continue
  fi

  apt_pkg="$(map_formula_to_apt "$normalized")"
  if [ -z "$apt_pkg" ]; then
    if is_unique "$normalized" "${unmapped[@]}"; then
      unmapped+=("$normalized")
    fi
    continue
  fi

  if is_unique "$apt_pkg" "${apt_packages[@]}"; then
    apt_packages+=("$apt_pkg")
  fi
done < <(read_formulas)

if [ "$SKIP_UPDATE" -ne 1 ]; then
  run_with_sudo apt-get update
fi

available_apt=()
for pkg in "${apt_packages[@]}"; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    available_apt+=("$pkg")
  else
    unavailable_apt+=("$pkg")
  fi
done

printf '\nPlan summary:\n'
printf '  apt install candidates: %s\n' "${#available_apt[@]}"
printf '  GUI skipped: %s\n' "${#skipped_gui[@]}"
printf '  no apt mapping: %s\n' "${#unmapped[@]}"
printf '  mapped but unavailable in apt: %s\n\n' "${#unavailable_apt[@]}"

if [ "${#available_apt[@]}" -gt 0 ]; then
  printf 'APT packages to install:\n'
  printf '  %s\n' "${available_apt[@]}"
  printf '\n'
fi

if [ "${#skipped_gui[@]}" -gt 0 ]; then
  printf 'GUI/macOS-only formulas skipped:\n'
  printf '  %s\n' "${skipped_gui[@]}"
  printf '\n'
fi

if [ "${#unavailable_apt[@]}" -gt 0 ]; then
  printf 'Mapped formulas unavailable in current apt repos:\n'
  printf '  %s\n' "${unavailable_apt[@]}"
  printf '\n'
fi

if [ "${#unmapped[@]}" -gt 0 ]; then
  printf 'Formulas requiring manual fallback:\n'
  for formula in "${unmapped[@]}"; do
    printf '  %s -> %s' "$formula" "$(fallback_hint "$formula")"
  done
  printf '\n'
fi

if [ "$DRY_RUN" -eq 1 ]; then
  printf 'Dry run enabled. Nothing installed.\n'
  exit 0
fi

if [ "${#available_apt[@]}" -gt 0 ]; then
  run_with_sudo apt-get install -y "${available_apt[@]}"
fi

printf 'Done.\n'
