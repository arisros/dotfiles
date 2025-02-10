return {
    'nvim-flutter/flutter-tools.nvim',
    lazy = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = function ()
      require("flutter-tools").setup({
        flutter_path = "/Users/arisjirat/fvm/default/bin",
        fvm = {
          sdk = "/Users/arisjirat/fvm/versions/3.24.0",
        },
      })
    end,
}
