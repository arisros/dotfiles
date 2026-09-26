# Architecture

## Repo to machine

```mermaid
flowchart LR
  subgraph repo["~/dotfiles (public, identical everywhere)"]
    PKG["stow packages<br/>zsh git ssh nvim tmux ..."]
    TPL["*/com.user.*.plist"]
    SCR["__scripts__/"]
  end
  subgraph local["machine-local (never committed)"]
    MOD["~/.config/dotfiles/modules/*.zsh"]
    PLG["~/.config/dotfiles/plugins/*"]
    INC["config.local / config.overlay<br/>local.conf, lua/local"]
  end
  PKG -->|"stow -R --adopt"| HOME["$HOME, ~/.config/*, ~/.ssh, ~/.claude"]
  TPL -->|"sed __HOME__, darwin only"| LA["~/Library/LaunchAgents"]
  SCR -->|"called by install.sh"| HOME
  PLG -->|"each install.sh"| INC
  MOD & INC -.->|"sourced / included if present"| HOME
```

## install.sh

```mermaid
flowchart TD
  A["detect OS: darwin | linux"] --> B["core: git, stow (required), curl"]
  B --> C{"DOTFILES_SKIP_OPTIONAL_TOOLS"}
  C -->|0| D["optional tools: zsh tmux nvim lazygit rg jq gpg pass clang ..."]
  D --> E{"linux?"}
  E -->|yes| F["apt: __scripts__/debian-packages.txt"]
  E -->|no| G
  F --> G["install_zsh_plugins.sh"]
  C -->|1| H
  G --> H["mkdir modules dir + target dirs"]
  H --> I["stow every package<br/>failures collected, loop continues"]
  I --> J["darwin: render LaunchAgents"]
  J --> K["touch ~/.claude/context.local.md"]
  K --> L["run each plugin install.sh"]
  L --> M["tmux: ~/.tmux.conf link, tpm clone, install_plugins"]
  M --> N["install_git_hooks.sh"]
  N --> O["sandi-setup.sh --quiet (opt-in)"]
  O --> P{"linux?"}
  P -->|yes| Q["brew leaves bridge, install_rust_tools.sh (yazi)"]
  P -->|no| R
  Q --> R["mise install"]
  R --> S["OpenCode + oh-my-opencode"]
  S --> T{"stow failures?"}
  T -->|yes| X["exit 1"]
  T -->|no| Y["done"]
```

Every step checks before acting (`command -v`, `mkdir -p`, `stow -R`), so re-running is safe. `--adopt` is on by default: a real file already at a target is pulled **into the repo**, check `git diff` after a first run.

## Stow map

| Package | Target | OS |
|---|---|---|
| `zsh`, `git`, `vim`, `lynx`, `opencode` | `$HOME` | all |
| `ssh` | `~/.ssh` | all |
| `claude` | `~/.claude` | all |
| `nvim` `tmux` `alacritty` `ghostty` `herdr` `mise` `yazi` `htop` `nix` | `~/.config/<pkg>` | all |
| `aerospace` `borders` `sketchybar` | `~/.config/<pkg>` | darwin |

Target directories are created first, so stow links files into them instead of folding the whole directory into one symlink.

Not stowed: `karabiner` (see [desktop](desktop.md)), `joshuto`, `rainfrog`. The `Brewfile` is not applied by `install.sh`.

## Where to go next

| Topic | Page |
|---|---|
| zsh load order, local modules | [shell.md](shell.md) |
| secrets, sandi, secret scanning, CI | [secrets.md](secrets.md) |
| git identity, ssh accounts, agent forwarding | [git-ssh.md](git-ssh.md) |
| macOS window manager and keyboard stack | [desktop.md](desktop.md) |
| attaching private config | [plugins.md](plugins.md) |
| install toggles, Debian bridge, C tooling | [reference.md](reference.md) |
