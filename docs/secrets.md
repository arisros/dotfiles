# Secrets

Secrets live in `pass`, encrypted to every key in `.gpg-id`. They are resolved into the one process that needs them and never written to disk.

## sandi env

```mermaid
sequenceDiagram
  participant U as shell
  participant S as sandi env
  participant P as pass / gpg
  participant C as child process
  U->>S: sandi env OPENAI_API_KEY=openai/api-key -- opencode
  loop each VAR=entry
    S->>P: pass show entry
    P-->>S: first line, or nothing
    Note over S: missing entry: warn, leave VAR unset
  end
  S->>C: env VAR=value ... opencode
  Note over C: values exist only here
```

Worked example: `zsh/.opencode_aliases`, since `opencode.json` reads its keys as `{env:VAR}`.

There is deliberately no `~/.secrets`. A plaintext dump sourced by every shell undoes the encryption, and it silently held empty values whenever a decrypt failed.

## Commands

| Command | Does |
|---|---|
| `sandi env VAR=entry ... -- cmd` | run `cmd` with resolved entries |
| `sandi sync` | `pull --rebase`, then `push` |
| `sandi st` | print sync state |
| anything else | passed through to `pass` (`show`, `find`, `insert`, `git`, ...); `find` matches filenames, so it is offline and decrypts nothing |

## Sync

```mermaid
sequenceDiagram
  participant A as machine A
  participant R as remote (ciphertext only)
  participant B as machine B
  A->>A: pass insert / edit (commit)
  A-)R: post-commit hook: git push, background
  B->>R: sandi sync: pull --rebase
  R-->>B: new entries
  B->>R: push local commits
```

The remote holds no key and can decrypt nothing. `.gpg` files are binary: two offline edits of the **same** entry conflict and are resolved by picking a side and re-inserting. Different entries merge cleanly.

## Setup (opt-in)

```mermaid
flowchart TD
  A["sandi-setup.sh (run by install.sh)"] --> B{"pass, gpg and store exist?"}
  B -->|no| Z["exit 0"]
  B -->|yes| C{"SANDI_REMOTE or DOTFILES_SANDI=1?"}
  C -->|no| Z2["leave ~/.password-store untouched"]
  C -->|yes| D["store .gitignore, pass git init, add origin"]
  D --> E["install versioned post-commit push hook<br/>never overwrites a hook it did not write"]
  E --> F["print state, --no-fetch"]
```

Set the remote in a machine-local module:

```bash
# ~/.config/dotfiles/modules/sandi.zsh
export SANDI_REMOTE="yourhost:path/to/password-store.git"
```

## State

`__scripts__/sandi-state.sh` is the single source for sync state. The first matching check wins:

```mermaid
flowchart TD
  A{"store dir?"} -->|no| NS["nostore"]
  A -->|yes| B{"git repo?"}
  B -->|no| NG["nogit"]
  B -->|yes| C{"uncommitted?"}
  C -->|yes| DI["dirty N"]
  C -->|no| D{"upstream?"}
  D -->|"no, has origin"| UP["unpushed"]
  D -->|"no origin"| NR["noremote"]
  D -->|yes| E{"fetch ok?<br/>skipped with --no-fetch"}
  E -->|no| OF["offline"]
  E -->|yes| F["ahead N / behind N / diverged N M / synced"]
```

The fetch uses `BatchMode=yes` and `ConnectTimeout=${SANDI_CONNECT_TIMEOUT:-3}`. The sketchybar item (`S:ok`, `S:^2`, `S:v1`) calls it with `--no-fetch` and ships commented out in `sketchybar/sketchybarrc`.

## Guardrails

```mermaid
flowchart LR
  subgraph local
    PC["pre-commit<br/>scan_secrets.sh --staged"]
    PP["pre-push<br/>gitleaks --no-git<br/>fallback: scan_secrets.sh --tracked"]
  end
  subgraph ci["GitHub Actions"]
    SC["shellcheck"]
    PK["debian 12: apt list resolves"]
    SM["debian 12: install.sh smoke"]
  end
  commit --> PC --> push --> PP --> ci
```

| Piece | Notes |
|---|---|
| `scan_secrets.sh` | regexes for private keys, AWS, GitHub, Google, Slack, `sk-`, literal IPs in ssh `HostName`; extra `label\|regex` lines from `$DOTFILES_MODULES/forbidden-patterns.txt` |
| pre-push | scans the whole working tree, ignored files included |
| `install_git_hooks.sh` | **copies** `.githooks/*` into `.git/hooks`; re-run after editing a hook |
| smoke test | stow result, macOS-only dirs absent on Linux, nvim > 0.7, `zsh -i` with empty stderr, ssh and git configs parse |
