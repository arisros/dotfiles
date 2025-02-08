return {
  "github/copilot.vim",
  lazy = false, -- Load Copilot immediately
  config = function()
    -- vim.g.copilot_no_tab_map = true -- Disable default Tab mapping


    -- Set the keymap for Copilot
    vim.api.nvim_set_keymap("i", "<C-Space>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
  end,
}
