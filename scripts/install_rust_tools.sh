#!/usr/bin/env bash
# Install Rust-based CLI tools that aren't packaged in apt:
#   - yazi (file manager)
#   - joshuto (file manager)
#
# Prefers prebuilt GitHub release binaries (small, fast, no compile). Falls
# back to `cargo install` if no matching release asset is found.
# On macOS these come from Brewfile — this script is a no-op there.
set -euo pipefail

if [ "$(uname -s)" = "Darwin" ]; then
    echo "==> macOS: yazi/joshuto come from Brewfile, skipping"
    exit 0
fi

ARCH="$(uname -m)"
DEST_BIN="$HOME/.local/bin"
mkdir -p "$DEST_BIN"

# --- helpers ---------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

# Download $url, extract the named binary (located by name), place at $DEST_BIN/$name.
# Args: name url
install_release() {
    local name="$1" url="$2"
    if have "$name"; then
        echo "==> $name already installed: $(command -v "$name")"
        return 0
    fi
    local tmp; tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN
    echo "==> Downloading $name from $url"
    curl -fsSL -o "$tmp/asset" "$url"

    case "$url" in
        *.zip)    (cd "$tmp" && unzip -q asset) ;;
        *.tar.gz) tar -xzf "$tmp/asset" -C "$tmp" ;;
        *.tar.xz) tar -xJf "$tmp/asset" -C "$tmp" ;;
        *)        echo "Unsupported archive format: $url" >&2; return 1 ;;
    esac

    local bin
    bin="$(find "$tmp" -type f -name "$name" -perm -u+x | head -1)"
    if [ -z "$bin" ]; then
        echo "Could not find binary '$name' inside the archive" >&2
        return 1
    fi
    install -m 0755 "$bin" "$DEST_BIN/$name"
    echo "==> Installed: $("$DEST_BIN/$name" --version 2>&1 | head -1)"
}

# --- yazi ------------------------------------------------------------------
# Use musl (statically linked) so it works on any glibc — the gnu builds
# require GLIBC 2.39+ which Debian 12 doesn't have.
case "$ARCH" in
    x86_64)  yazi_asset="yazi-x86_64-unknown-linux-musl.zip" ;;
    aarch64) yazi_asset="yazi-aarch64-unknown-linux-musl.zip" ;;
    *)       echo "Unsupported arch for yazi: $ARCH" >&2; exit 1 ;;
esac

# yazi's archive contains both `yazi` and `ya` (the CLI). Install both.
install_release yazi \
    "https://github.com/sxyazi/yazi/releases/latest/download/$yazi_asset"
# Pull `ya` (the CLI) out of the same archive on the next run.
if ! have ya; then
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/y.zip" \
        "https://github.com/sxyazi/yazi/releases/latest/download/$yazi_asset"
    (cd "$tmp" && unzip -q y.zip)
    ya_bin="$(find "$tmp" -type f -name ya | head -1)"
    [ -n "$ya_bin" ] && install -m 0755 "$ya_bin" "$DEST_BIN/ya"
    rm -rf "$tmp"
fi

# --- joshuto ---------------------------------------------------------------
# joshuto does not publish prebuilt release binaries — only source. Building
# from cargo needs ~1.5GB of disk for build artifacts. Skip silently if cargo
# is missing or disk is tight; users with space can re-run with
# JOSHUTO_FORCE_CARGO=1 to compile from source.
if ! have joshuto && [ "${JOSHUTO_FORCE_CARGO:-0}" = "1" ] && have cargo; then
    echo "==> cargo install joshuto (this will take several minutes)"
    cargo install --locked joshuto
else
    echo "==> joshuto: skipped (no prebuilt binary upstream). To install, run:"
    echo "    JOSHUTO_FORCE_CARGO=1 bash scripts/install_rust_tools.sh"
fi
