# Shell

## .zshrc load order

```mermaid
flowchart TD
  A["OS flags, macOS Homebrew / CGO / sketchybar env"] --> B["brew shellenv, mise activate"]
  B --> C["git-prompt, autosuggestions, syntax-highlighting"]
  C --> D["vi mode, history, history-substring-search, compinit"]
  D --> E["nvm"]
  E --> F["ssh agent socket"]
  F --> G["PATH: fvm, flutter, android, java, ~/.local/bin"]
  G --> H["mise activate (again)"]
  H --> I["alias files"]
  I --> J["local modules: ~/.config/dotfiles/modules/*.zsh"]
  J --> K["arduino completion, nix-daemon"]
  K --> L["SDKMAN, phpvm, opencode PATH, wt"]
  L --> M["macOS sleep helpers: lock / hard / normal"]
```

Modules load after every alias file, so a module can override any alias or function from this repo.

## Alias files

| File | Purpose |
|---|---|
| `.config_restart_aliases` | reload configs |
| `.fs_aliases` | filesystem, `oc-init` scaffold |
| `.functions` | general helpers |
| `.git_aliases` | git |
| `.docker_aliases` | docker |
| `.runpod_aliases` | runpod, uses `__scripts__/rpdash.py` |
| `.db_aliases` | databases |
| `.sandi_aliases` | `sandi`, see [secrets.md](secrets.md) |
| `.opencode_aliases` | `opencode` wrapped with `sandi env` |

## ssh agent socket

```mermaid
flowchart LR
  S{"SSH_CONNECTION set?"} -->|yes| L["ln -sfn forwarded socket ~/.ssh/agent.sock<br/>export SSH_AUTH_SOCK=agent.sock"]
  S -->|no| C{"SSH_AUTH_SOCK is a socket?"}
  L --> C
  C -->|no| A["start ssh-agent"]
  C -->|yes| D["use it"]
```

tmux panes keep the socket path they started with. The fixed symlink is re-pointed on every login, so a pane that outlives its connection still reaches the agent.

## Local hooks

| File | Read by |
|---|---|
| `~/.config/dotfiles/modules/*.zsh` | `zsh/.zshrc` |
| `~/.config/tmux/local.conf` | `tmux/tmux.conf`, `source-file -q` |
| `~/.config/nvim/lua/local/init.lua` | `nvim/init.lua`, `pcall(require, "local")` |

All are optional and silent when missing. The full hook list is in [plugins.md](plugins.md).
