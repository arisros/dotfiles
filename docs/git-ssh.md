# Git and SSH

## Config layering

```mermaid
flowchart TD
  subgraph git["~/.gitconfig (git/.gitconfig)"]
    G1["https://github.com/ insteadOf git@github.com:"]
    G2["credential: gh auth git-credential"]
    G3["include ~/.config/git/config.local"]
    G4["include ~/.config/git/config.overlay"]
    G1 --> G2 --> G3 --> G4
  end
  subgraph ssh["~/.ssh/config (ssh/config)"]
    S1["IgnoreUnknown UseKeychain"]
    S2["Include OrbStack"]
    S3["Include ~/.ssh/config.local"]
    S4["Include ~/.ssh/config.d/*"]
    S5["Host *: AddKeysToAgent, IdentitiesOnly yes, ServerAlive"]
    S1 --> S2 --> S3 --> S4 --> S5
  end
```

Git applies includes in order and the last value wins, so `config.overlay` beats `config.local`. ssh takes the **first** value, so the includes sit above `Host *`. Shapes: `git/config.local.example`, `ssh/config.local.example`. Include ordering pitfalls: [plugins.md](plugins.md).

## Multiple GitHub accounts

Repos are routed to an account by the org in the remote URL, not by the directory they are cloned into.

```mermaid
flowchart LR
  R["git@github.com:ORG/x"] -->|insteadOf| A["ALIAS:ORG/x"]
  A --> H1["Host ALIAS: work key"]
  P["git@github.com:YOU/x"] --> H2["Host github.com: personal key"]
  H1 & H2 --> K{"private key on this machine?"}
  K -->|yes| U["use it"]
  K -->|"only the .pub"| F["pick that key from the forwarded agent"]
```

| Piece | Where |
|---|---|
| `url "<alias>:<org>/".insteadOf` | `~/.config/git/config.local` |
| `includeIf "hasconfig:remote.*.url:..."` for identity | `~/.config/git/config.local` or `.overlay` |
| `Host <alias>` with its own `IdentityFile` | `~/.ssh/config.local` |
| explicit `Host github.com` `IdentityFile` | `~/.ssh/config.local`, needed because `IdentitiesOnly yes` |

Check: `ssh -T git@github.com` and `ssh -T <alias>` each greet their own user. `git config --show-origin --get user.email` names the file that set the identity.

## Other machines, no private keys

```mermaid
sequenceDiagram
  participant L as laptop
  participant K as macOS keychain
  participant V as remote (homelab, VM)
  participant G as GitHub
  K->>L: login: com.user.ssh-agent loads every key
  L->>V: ssh, ForwardAgent yes (this host only)
  Note over V: .zshrc links ~/.ssh/agent.sock to the forwarded socket
  V->>G: git push via ALIAS
  Note over V: only ALIAS key .pub exists, ssh asks the agent for that key
  G-->>V: authenticated as that account
```

1. Laptop: `ForwardAgent yes` on that one host in `~/.ssh/config.local`.
2. Remote: copy only the `.pub` files to `~/.ssh/`, reuse the same aliases.
