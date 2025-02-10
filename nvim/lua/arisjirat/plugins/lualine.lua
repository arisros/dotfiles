return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
          component_separators = {'', ''},
          section_separators = {'', ''},
        },
        sections = {
          lualine_c = { { 'filename', path = 1 } }, -- Show full path
        }
      })

    end,
}
