# karabiner — tmux-style browser navigation

Brings the tmux prefix grammar into Chrome/Brave, so `Home` means the same thing
in the terminal and in the browser.

`tmux-browser.json` is a Karabiner **complex modifications** asset. It is stowed
into `~/.config/karabiner/assets/complex_modifications/`, which Karabiner only
ever *reads* — unlike `karabiner.json`, which Karabiner rewrites on every change
and which therefore cannot be symlinked (see upstream issue #3248).

## Enabling

`install.sh` does it — `scripts/install_karabiner_rules.sh` runs after the stow
and merges both rules into the selected profile. Re-run it on its own after
editing the rules:

    bash scripts/install_karabiner_rules.sh

It is idempotent (rules are matched by description and replaced), preserves any
rules you added yourself, backs up `karabiner.json` first, and overwrites in
place so Karabiner's file watcher reloads without a restart. If Karabiner has
never been launched there is no `karabiner.json` yet; the script says so and
exits without doing anything.

This exists because Karabiner has no CLI for enabling a rule — `karabiner_cli`
can only *lint* one. The GUI's "Add rule" copies the rule out of
`assets/complex_modifications/` into `karabiner.json`, and the script does the
same thing directly. The GUI route still works if you prefer it:
Karabiner-Elements → Complex Modifications → Add rule, enabling
**"tmux prefix in the browser"** before **"caps_lock -> home"**.

That order matters either way: both rules bind `caps_lock`, and Karabiner
applies manipulators top-down. Rule 1 claims `caps_lock` only while a browser is
frontmost; outside the browser its condition fails and rule 2 takes over. The
script preserves the order the rules appear in `tmux-browser.json`.

## The prefix

Three ways to fire it, all producing the same layer:

| Trigger | Where it comes from |
|---|---|
| `Home` | ArkButton right-thumb key (`charybdis_handwired.keymap:49`) |
| `fn`+`←` | MacBook built-in keyboard — macOS' own Home |
| `caps_lock` | via rule 2; ArkButton has no caps_lock, this is for the built-in board |

The `left_arrow`+`fn` manipulator is a belt-and-braces entry: Karabiner may report
`fn`+`←` either as `home`+fn (caught by the first manipulator, which accepts any
modifier) or as `left_arrow`+fn. Whichever it is on a given machine, one of the
two matches and the other never fires. Confirm with Karabiner-EventViewer.

The prefix disarms after **2000 ms** (`basic.to_delayed_action_delay_milliseconds`).
tmux itself waits indefinitely; a timeout was chosen so a stray `Home` cannot
leave the next keystroke reinterpreted. Delete `to_delayed_action` to match tmux.

## The map

Left column is what `tmux list-keys -T prefix` reports for this repo's tmux.conf.

| tmux | browser | sent |
|---|---|---|
| `1`–`9` select-window | tab 1–8; `9` = **last** tab | `Cmd`+N |
| `n` next-window | next tab | `Cmd`+`Opt`+`→` |
| `Space` next-window (custom) | next tab | `Cmd`+`Opt`+`→` |
| `p` previous-window | previous tab | `Cmd`+`Opt`+`←` |
| `c` new-window | new tab | `Cmd`+`T` |
| `x` kill-pane | close tab | `Cmd`+`W` |
| `&` kill-window | close tab | `Cmd`+`W` |
| `w` choose-tree | tab search | `Cmd`+`Shift`+`A` |
| `s` choose-tree -Zs | tab search | `Cmd`+`Shift`+`A` |
| `f` find-window | tab search | `Cmd`+`Shift`+`A` |
| `:` command-prompt | address bar | `Cmd`+`L` |
| `r` refresh-client | reload | `Cmd`+`R` |
| `z` resize-pane -Z | fullscreen | `Ctrl`+`Cmd`+`F` |
| `[` copy-mode | Vimium visual mode | `v` |
| `[` copy-mode (alt) | caret-browsing copy mode — see below | `F7` on `Home v` |
| `o` urlview (plugin) | Vimium link hints | `f` |
| `?` list-keys | Vimium help | `?` |
| `l` last-window¹ | previous tab visited | `^` |
| — | undo close tab² | `Cmd`+`Shift`+`T` |
| `Esc` | cancel the prefix | — |

¹ tmux's default `l` is last-window, but `tmux.conf:34` rebinds it to
`resize-pane -R`, so this restores a binding the terminal config gave up.
² No tmux equivalent; included because closing the wrong tab is cheap to undo.

`9` is a deliberate mismatch: Chrome's `Cmd`+`9` jumps to the *last* tab, not the
ninth. tmux's `9` selects window 9. Chrome has no ninth-tab shortcut.

## Why Karabiner owns the whole prefix

The bottom four rows are handed to Vimium by sending the keys Vimium already
binds by default — so Vimium needs no custom configuration.

That split is forced, not chosen. If Karabiner swallowed `Home` only for the
digits, it would still have to swallow it *before* knowing which key follows,
and Vimium would never receive `<home>` for its own sequences. One owner avoids
the race. It also means the number layer keeps working on `chrome://` pages, the
PDF viewer and the Web Store, where extensions cannot run at all.

Putting the layer in ZMK instead was considered and rejected: `&sl` is an exact
match for prefix semantics and would be OS-independent, but the keyboard cannot
know which application is focused, so `Home 1` would fire `Cmd-1` inside tmux and
break the terminal prefix. Per-application scoping is the requirement that pins
this to Karabiner, and therefore to macOS.

## Scope

macOS only. On Linux the equivalent is `keyd` or `xremap` with a different config
format — not covered here. Vimium works on both regardless; only the number layer
and the tmux letter grammar are lost.

## Two ways into copy mode

`Home [` and `Home v` both give you tmux's copy-mode; they differ in where the
cursor comes from.

`Home [` hands off to **Vimium's visual mode**. Motions are Vimium's own and
snap to DOM structure, which is the better tool when you are selecting a
paragraph or a code block. Its caret is small, does not blink much, and starts
wherever Vimium guesses — easy to lose.

`Home v` turns on **Chrome's native caret browsing** (`F7`) and layers tmux's
copy-mode keys over it. The cursor is the browser's own blinking text caret, so
you always know where you are, and because it is a browser feature rather than
an extension it also works on `chrome://` pages and in the PDF viewer.

| copy-mode-vi | sent |
|---|---|
| `h` `j` `k` `l` | `←` `↓` `↑` `→` |
| `w` / `b` | `Opt`+`→` / `Opt`+`←` |
| `0` / `$` | `Cmd`+`←` / `Cmd`+`→` |
| `g` / `G` | `Cmd`+`↑` / `Cmd`+`↓` |
| `C-u` / `C-d` | `PageUp` / `PageDown` |
| `v` begin-selection | every motion above gains `Shift` |
| `y` | `Cmd`+`C`, then exit |
| `/` | `Cmd`+`F` |
| `q`, `Esc` | exit |

`v` works by setting a second variable; while it is on, the selecting variants of
each motion are listed *before* the plain ones so Karabiner matches them first.
That is exactly tmux's `begin-selection`: anchor where the cursor is, extend as
you move.

Two things to check on first use. Chrome asks for confirmation the first time
`F7` arrives — once, with a "don't ask again" box. And `F7` can be swallowed as a
media key depending on *Use F1–F12 as standard function keys* in System Settings.

Exiting sends `F7` again to toggle caret browsing back off, so if you turn it off
some other way while the layer is active, the next exit will turn it back on.

## Seeing the state

tmux shows a red `●` in its status bar when the prefix is live
(`@minimal-tmux-indicator-str`, `tmux.conf:76`). The browser layer had no such
cue, which made a two-key sequence feel like a guess. Now it drives two:

- **sketchybar** — `macos/sketchybar/items/tmux_prefix.sh` adds a hidden item that
  appears as a red `●` labelled `PREFIX` or `COPY`. Same glyph, same colour, same
  top bar as tmux, so the two layers read identically.
- **JankyBorders** — the focused window's border turns the same red and returns to
  `0xffCC6766` on release. A dot in the corner is easy to miss; a frame around the
  whole window is not.

Both are driven by `scripts/karabiner-prefix-indicator.sh`, called from
`shell_command` on every arm and disarm. It sits in the path of a keystroke, so
it re-adds Homebrew to `PATH` (Karabiner's `shell_command` runs with a minimal
one), swallows every error, and always exits 0 — a missing sketchybar or borders
must never cost you a keypress. It resolves as `$HOME/dotfiles/...`, the same
assumption `tmux.conf:100` already makes for `osc52-copy.sh`.
