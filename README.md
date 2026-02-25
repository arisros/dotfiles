```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/arisros/dotfiles/main/install.sh)"
```

Or after cloning the repo:

```bash
./install.sh
```

## Cross-machine compatibility (macOS + Debian)

`install.sh` is now machine-aware and will:

- detect platform (`darwin` or `linux`)
- auto-install missing core dependencies (`git`, `stow`, `curl`) using Homebrew (macOS) or `apt-get` (Debian)
- best-effort install common tools (`tmux`, `neovim`, `ripgrep`, `jq`, `gnupg`, `pass`)
- attempt to install `mise` and run `mise install` from `mise/config.toml`
- install versioned git hooks and initialize `~/.secrets` template safely

If a package manager is unavailable for the current OS, the script exits with a clear actionable error.

Quick bootstrap:

- macOS: `./install.sh`
- Debian: `./install.sh` (uses `sudo apt-get` when needed)

Optional for faster first run:

```bash
DOTFILES_SKIP_MISE_INSTALL=1 ./install.sh
DOTFILES_SKIP_OPTIONAL_TOOLS=1 DOTFILES_SKIP_MISE_INSTALL=1 ./install.sh
DOTFILES_INSTALL_ZSH=1 DOTFILES_INSTALL_DEBIAN_BREW_EQUIV=1 ./install.sh
```

Shell strategy:

- default behavior: keep existing shell on machine (recommended for Debian portability)
- install zsh only when you explicitly want it:

```bash
DOTFILES_INSTALL_ZSH=1 ./install.sh
```

## New machine checklist (macOS + Debian)

Run this on every new machine:

```bash
git clone <your-dotfiles-repo>
cd dotfiles
./install.sh
./__scripts__/restore_credentials.sh --force
```

Quick verification:

```bash
zsh -i -c 'echo shell-ok'
tmux new -d -s tmux-check && tmux kill-session -t tmux-check
```

Platform notes:

- macOS: if Homebrew bootstrap fails, run `xcode-select --install` once, then rerun `./install.sh`.
- Debian: installer uses `sudo apt-get`; if `sudo` is not available, run installer as root.

Tmux style note:

- installer now bootstraps tmux compatibility by creating `~/.tmux.conf` -> `~/.config/tmux/tmux.conf` when missing and ensuring TPM/plugins are installed.

## Debian package bridge from Homebrew

Use this when you want Debian to install CLI equivalents of your Homebrew apps and skip GUI/macOS-only formulas by default.

You can run this directly, or set `DOTFILES_INSTALL_DEBIAN_BREW_EQUIV=1` in `./install.sh`.

1) Export your Homebrew leaves on macOS:

```bash
./__scripts__/export_brew_leaves.sh
```

2) On Debian, run dry-run first:

```bash
./__scripts__/install_debian_brew_equivalents.sh --from-file ./__scripts__/brew-leaves.txt --dry-run
```

3) Install available apt equivalents:

```bash
./__scripts__/install_debian_brew_equivalents.sh --from-file ./__scripts__/brew-leaves.txt
```

Notes:

- default behavior skips GUI/macOS-only formulas (`borders`, `sketchybar`, `mpv`)
- include GUI formulas explicitly with `--include-gui`
- script prints fallback hints for formulas without apt equivalents

## Mermaid chart rendering

Use the helper script to render Mermaid diagrams into `svg`, `png`, or `pdf`.

```bash
./__scripts__/render_mermaid.sh ./diagram.mmd svg
./__scripts__/render_mermaid.sh ./diagram.mmd png ./out/diagram.png
```

If `mmdc` is missing, install it with:

```bash
mise use -g npm:@mermaid-js/mermaid-cli@latest
```

## Secret scan hardening

Run the local high-confidence secret scan before commit/push:

```bash
./__scripts__/scan_secrets.sh --staged
./__scripts__/scan_secrets.sh --tracked
```

Enable the versioned pre-push hook in this repo:

```bash
./__scripts__/install_git_hooks.sh
```

The hook uses `gitleaks` when installed, and falls back to the local regex scanner otherwise.

## Credentials restore strategy (easy)

Priority strategy for multi-machine setup:

1. Keep real secrets out of git (`~/.secrets` is local only).
2. Keep secret source-of-truth in `pass` (password store) entries.
3. Restore to shell env with:

```bash
./__scripts__/restore_credentials.sh --force
```

Alternative restore methods:

```bash
# restore from environment variables currently in shell
OPENAI_API_KEY="..." OPENCODE_API_KEY="..." ./__scripts__/restore_credentials.sh --force

# restore from secure transferred file
./__scripts__/restore_credentials.sh --from-file ~/secure/.secrets --force
```

This script writes `~/.secrets` from available `pass` entries using these mappings:

- `openai/api-key` -> `OPENAI_API_KEY`
- `opencode/api-key` -> `OPENCODE_API_KEY`
- `anthropic/api-key` -> `ANTHROPIC_API_KEY`
- `google/api-key` -> `GOOGLE_API_KEY`
- `github/token` -> `GITHUB_TOKEN`

If `pass` is not installed/unlocked, it falls back to environment variables, then to template placeholders in `~/.secrets`.
