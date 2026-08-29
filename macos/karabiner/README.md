# karabiner — tmux-style browser navigation

Brings the tmux prefix grammar into Chrome/Brave, so `Home` means the same thing
in the terminal and in the browser.

`tmux-browser.json` is a Karabiner **complex modifications** asset. It is stowed
into `~/.config/karabiner/assets/complex_modifications/`, which Karabiner only
ever *reads* — unlike `karabiner.json`, which Karabiner rewrites on every change
and which therefore cannot be symlinked (see upstream issue #3248).

## Enabling

    Karabiner-Elements → Complex Modifications → Add rule

Enable **"tmux prefix in the browser"** first, then **"caps_lock -> home"**.
That order matters: both rules bind `caps_lock`, and Karabiner applies
manipulators top-down. Rule 1 claims `caps_lock` only while a browser is
frontmost; outside the browser its condition fails and rule 2 takes over.

Enabling copies the rule into `karabiner.json`, so **after editing this file you
must remove and re-add the rule** — there is no live reload.

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
