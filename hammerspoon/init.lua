-- Opens the message port the already-installed `hs` CLI talks to.
require("hs.ipc")

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

-- kbd off lasts one sitting: waking the machine, or reopening the lid on an
-- external display, hands the built-in keyboard back. Closing a laptop must
-- never be a way to end up with a keyboard that does nothing.
local builtinKeyboard = os.getenv("HOME") .. "/dotfiles/__scripts__/builtin-keyboard.sh"

local function restoreBuiltinKeyboard()
  hs.task.new(builtinKeyboard, nil, { "on" }):start()
end

local function builtInDisplayPresent()
  for _, screen in ipairs(hs.screen.allScreens()) do
    local name = screen:name()
    if name and name:match("^Built%-in") then
      return true
    end
  end
  return false
end

local builtInWasPresent = builtInDisplayPresent()

-- Both watchers are globals on purpose: Hammerspoon collects a watcher as soon
-- as nothing references it, and a local here would stop firing.
kbdWakeWatcher = hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.systemDidWake then
    restoreBuiltinKeyboard()
  end
end)
kbdWakeWatcher:start()

-- Closing the lid onto an external display never sleeps the machine, so the
-- only sign that it opened again is the built-in display coming back.
kbdScreenWatcher = hs.screen.watcher.new(function()
  local present = builtInDisplayPresent()
  if present and not builtInWasPresent then
    restoreBuiltinKeyboard()
  end
  builtInWasPresent = present
end)
kbdScreenWatcher:start()
