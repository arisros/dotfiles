# OpenCode.nvim Setup Guide

## 1. API Key Setup

API key sudah dikonfigurasi di `~/.secrets` yang otomatis di-load oleh `.zshrc`.

### Cara mendapatkan API Key:

1. Buka https://app.ohmyopencode.com/settings/api-keys
2. Buat API key baru
3. Copy API key tersebut
4. Edit file `~/.secrets`:
   ```bash
   nvim ~/.secrets
   ```
5. Ganti `your-api-key-here` dengan API key Anda:
   ```bash
   export OPENCODE_API_KEY="oc_xxxxxxxxxxxxxxxxxxxxxxxx"
   ```
6. Reload shell:
   ```bash
   source ~/.zshrc
   ```

### Verifikasi Setup:

```bash
echo $OPENCODE_API_KEY
```

Seharusnya menampilkan API key Anda (bukan kosong).

## 2. Konfigurasi di Neovim

File konfigurasi: `~/.config/nvim/lua/arisjirat/plugins/opencode.lua`

### API Configuration:
```lua
api = {
    base_url = os.getenv("OPENCODE_API_URL") or "https://api.ohmyopencode.com",
    api_key = os.getenv("OPENCODE_API_KEY"),
}
```

**Environment Variables:**
- `OPENCODE_API_KEY` (Required): API key dari OhMyOpenCode
- `OPENCODE_API_URL` (Optional): Custom API URL untuk self-hosted instance

### Default Settings:
```lua
model = {
    default = "claude-sonnet-4",
    temperature = 0.7,
    max_tokens = 8192,
}
```

## 3. Keybindings

Semua keybindings menggunakan prefix `<leader>o` (default leader: Space)

### Chat & Interaction
| Key | Mode | Action |
|-----|------|--------|
| `<leader>oc` | Normal | Open OpenCode chat |
| `<leader>oo` | Normal | Toggle OpenCode window |
| `<leader>oe` | Visual | Explain selected code |
| `<leader>or` | Visual | Refactor selected code |
| `<leader>of` | Visual | Fix selected code |

### File Operations
| Key | Mode | Action |
|-----|------|--------|
| `<leader>od` | Normal | Generate documentation |
| `<leader>ot` | Normal | Generate tests |
| `<leader>op` | Normal | Optimize code |

### Context Management
| Key | Mode | Action |
|-----|------|--------|
| `<leader>oa` | Normal | Add file to context |
| `<leader>ox` | Normal | Clear context |
| `<leader>ol` | Normal | List context files |

### Diagnostics Integration
| Key | Mode | Action |
|-----|------|--------|
| `<leader>oD` | Normal | Fix all diagnostics in file |
| `<leader>oh` | Normal | Fix diagnostics on current line |
| `<leader>oF` | Normal | Fix with OpenCode (LSP attached) |

### History & Sessions
| Key | Mode | Action |
|-----|------|--------|
| `<leader>oh` | Normal | OpenCode chat history (Telescope) |
| `<leader>os` | Normal | OpenCode sessions (Telescope) |

### Quick Actions
| Key | Mode | Action |
|-----|------|--------|
| `<leader>oq` | Normal/Visual | Quick prompt |

### Telescope Integration
| Key | Mode | Action |
|-----|------|--------|
| `<leader>fc` | Normal | OpenCode commands picker |
| `<leader>fp` | Normal | OpenCode prompts picker |

## 4. Custom Commands

### `:OpenCodeCommitMsg`
Generate commit message dari staged changes:
```vim
:OpenCodeCommitMsg
```

### `:OpenCodeExplainError`
Explain LSP error di baris cursor:
```vim
:OpenCodeExplainError
```

### `:OpenCodeSmartRefactor [prompt]`
Refactor dengan LSP context:
```vim
:OpenCodeSmartRefactor make this more efficient
```

## 5. Auto-Commands

### Auto Format
Setelah OpenCode generate code, otomatis format menggunakan `conform.nvim`:
- Event: `OpenCodeGenerateComplete`
- Requires: `code_actions.auto_format = true`

### Auto Save
Optional auto save setelah apply changes:
- Event: `OpenCodeApplyComplete`
- Requires: `code_actions.auto_save = true`

### LSP Integration
Saat LSP attach, otomatis register keymap `<leader>oF` untuk quick fix dengan OpenCode.

## 6. Workflow Examples

### Example 1: Fix Code dengan Selection
1. Visual select kode yang bermasalah
2. Press `<leader>of`
3. OpenCode akan analyze dan suggest fix
4. Accept/reject changes

### Example 2: Generate Documentation
1. Posisikan cursor di function/class
2. Press `<leader>od`
3. OpenCode generate documentation
4. Auto format via conform.nvim

### Example 3: Explain LSP Error
1. Posisikan cursor di line dengan error
2. Press `<leader>oF` atau `:OpenCodeExplainError`
3. OpenCode explain error dan suggest fix

### Example 4: Commit Message Generation
1. Stage changes: `git add .`
2. Run: `:OpenCodeCommitMsg`
3. OpenCode generate commit message berdasarkan diff
4. Review dan commit

## 7. Integrasi dengan Existing Tools

### LSP Integration
- Auto include diagnostics dalam context
- Auto include hover info
- Custom keymap saat LSP attach

### Telescope Integration
- Theme: "ivy" (matching existing config)
- Pickers: commands, prompts, history, sessions

### Conform.nvim Integration
- Auto format after code generation
- Use existing formatters configuration

### nvim-cmp Integration
- Completion source dari OpenCode

## 8. Status Line Integration

Optional status line function:
```lua
_G.opencode_status()
```

Returns:
- `"🤖 [message]"` when OpenCode is active
- `""` when inactive

Add to your statusline config untuk show OpenCode status.

## 9. Troubleshooting

### API Key tidak detected
```bash
source ~/.zshrc
echo $OPENCODE_API_KEY
```

### OpenCode commands tidak tersedia
```vim
:checkhealth opencode
```

### Telescope integration tidak jalan
Check Telescope loaded:
```vim
:Telescope
```

### Format tidak jalan setelah generate
Check conform.nvim:
```vim
:ConformInfo
```

## 10. Advanced Configuration

### Custom API URL (Self-hosted)
Edit `~/.secrets`:
```bash
export OPENCODE_API_URL="https://your-custom-api.com"
```

### Disable Auto Format
Edit `opencode.lua`:
```lua
code_actions = {
    auto_format = false,
}
```

### Enable Auto Save
Edit `opencode.lua`:
```lua
code_actions = {
    auto_save = true,
}
```

### Adjust Model Settings
Edit `opencode.lua`:
```lua
model = {
    default = "claude-sonnet-4",
    temperature = 0.5,  -- Lower = more deterministic
    max_tokens = 16384, -- Increase for longer responses
}
```
