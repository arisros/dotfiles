# Desktop (macOS)

Only darwin gets this stack. On Linux none of it is stowed.

## How the pieces talk

```mermaid
flowchart LR
  subgraph launchd["LaunchAgents (rendered by install.sh)"]
    LS["com.user.sketchybar"]
    LB["com.user.borders"]
    LK["com.user.ssh-agent<br/>ssh-add --apple-load-keychain"]
  end
  subgraph kb["Karabiner"]
    KR["tmux-browser.json<br/>Home / caps_lock prefix in the browser"]
    KB["builtin-keyboard.json<br/>kbd off: MacBook keys swallowed"]
  end
  AE["AeroSpace"] -->|"exec-on-workspace-change<br/>--trigger aerospace_workspace_change"| SB["SketchyBar"]
  KR -->|"shell_command prefix | copy | off"| KI["__scripts__/karabiner-prefix-indicator.sh"]
  KI -->|"--set tmux_prefix label=PREFIX/COPY"| SB
  KI -->|"active_color red / idle"| BO["JankyBorders"]
  LS --> SB
  LB --> BO
```

| Piece | Config | Started by |
|---|---|---|
| AeroSpace | `aerospace/aerospace.toml` | `start-at-login = true` |
| SketchyBar | `sketchybar/sketchybarrc` | LaunchAgent |
| JankyBorders | `borders/bordersrc` | LaunchAgent |
| Karabiner rules | `karabiner/*.json` | merged by `install.sh`, see below |
| Hammerspoon | `hammerspoon/init.lua` | open it once, then "Launch at login" in its preferences |

`install.sh` writes the plists but never runs `launchctl load`; they start at next login.

## Browser prefix layer

```mermaid
stateDiagram-v2
  [*] --> idle
  idle --> prefix: Home, fn+left, caps_lock
  prefix --> idle: mapped key sent, Esc, or 2000 ms
  prefix --> copy: v (caret browsing, F7)
  copy --> idle: y, q, Esc
  note right of prefix: sketchybar PREFIX, red border
  note right of copy: sketchybar COPY, red border
```

The rules are **not** stowed. `install.sh` and `dots-sync` (so every `git pull`, through the post-merge hook) merge them into `karabiner.json`. After editing a rule locally, apply it directly:

```bash
bash __scripts__/install_karabiner_rules.sh
```

Key map, copy-mode keys and design notes: [karabiner/README.md](../karabiner/README.md).

## Built-in keyboard switch

```bash
kbd off      # the MacBook's own keys stop doing anything
kbd on       # back
kbd status   # the default with no argument
```

For when an external keyboard sits on top of the laptop, or the laptop needs a
wipe. Nothing else is touched: trackpad, external keyboards and everything plugged
in keep working.

`builtin-keyboard.json` swallows the built-in keyboard while the Karabiner
variable `builtin_keyboard_disabled` is `1`; `__scripts__/builtin-keyboard.sh` is
the only thing that sets it, and `zsh/.functions` wraps it as `kbd`. The variable
is never written to disk, so quitting Karabiner, logging out or rebooting gives
the keyboard back. Details and the way out when no second keyboard is connected:
[karabiner/README.md](../karabiner/README.md).

## Browser link to nvim

Neovim has no URL scheme, so a web page cannot open a file in it directly. Hammerspoon registers one and hands the file to `__scripts__/nvim-open.sh`.

```mermaid
flowchart TB
  B["link in the browser<br/>hammerspoon://nvim?file=/abs/path&line=12"] --> H["Hammerspoon<br/>hammerspoon/init.lua"]
  H --> S["__scripts__/nvim-open.sh path line"]
  S -->|"nvim --server sock --remote-expr"| N["the running nvim whose cwd holds the file"]
  S -->|"switch-client, select-pane"| X["its tmux pane"]
  S -->|"open -a Ghostty"| T["terminal to the front"]
```

With no nvim running, the script opens one in a new tmux window. The browser asks once before it hands a link to Hammerspoon.

For fate-studio:

```sh
fate-studio --editor-url "hammerspoon://nvim?file={path}&line={line}"
```

The script also works alone, on Linux too, for any tool that can run a command: `nvim-open.sh <path> [line]`.

## Terminal

```mermaid
flowchart LR
  T["ghostty / alacritty"] --> X["tmux"]
  X -->|"vim-tmux-navigator<br/>C-h/j/k/l across panes"| N["nvim"]
  X -->|"source-file -q"| XL["~/.config/tmux/local.conf"]
  N -->|"pcall(require, 'local')"| NL["~/.config/nvim/lua/local"]
  I["install.sh"] -->|"clone tpm, install_plugins"| X
```

| Piece | Entry |
|---|---|
| tmux | `tmux/tmux.conf`; plugins via tpm (sensible, resurrect, continuum, vim-tmux-navigator, minimal-tmux-status, urlview, yank) |
| nvim | `nvim/init.lua` then `arisjirat.core`, `arisjirat.lazy` (lazy.nvim) |
| terminals | font and window only, no shell or tmux wiring |
