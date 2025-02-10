return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup()
  end,
  opts = {
    on_attach = function(client)
      local gs = package.loaded.gitsigns

      function map(mode, key, action, desc)
        vim.keymap.set(mode, key, action, { buffer = client, desc = desc })
      end

      -- blame line 
      map('n', '<leader>hb', function()
        gs.blame_line(true)
      end, 'Blame current line')
    end,
  }
}
