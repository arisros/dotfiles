vim.o.showtabline = 1
require("arisjirat.core")
require("arisjirat.lazy")

-- Optional local module: nvim/lua/local/init.lua, untracked. Absent is fine.
pcall(require, "local")
