return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- require('lualine').get_config() 
      require('lualine').setup({
        sections = {
          lualine_a = {
            {
              path = 1
            }
          }
        }
      })

    end,
}
