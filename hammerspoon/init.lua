-- hammerspoon://nvim?file=/abs/path&line=12 opens the file in a running Neovim
-- and raises the terminal. Neovim has no URL scheme of its own, so this is what
-- lets a link in the browser (fate-studio --editor-url) land in the editor.
local opener = os.getenv("HOME") .. "/dotfiles/__scripts__/nvim-open.sh"
local terminal = "Ghostty"

hs.urlevent.bind("nvim", function(_, params)
  if not params.file then
    return
  end
  hs.task
    .new("/usr/bin/env", function(code, _, err)
      if code ~= 0 then
        hs.alert.show("nvim-open: " .. (err ~= "" and err or "exit " .. code))
      end
    end, {
      -- Hammerspoon starts with launchd's PATH, which has no Homebrew.
      "PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin",
      "NVIM_OPEN_APP=" .. terminal,
      "bash",
      opener,
      params.file,
      params.line or "1",
    })
    :start()
end)
