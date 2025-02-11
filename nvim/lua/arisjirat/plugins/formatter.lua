return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require('conform')
    conform.setup({
      formatters_by_ft = {
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        javascriptreact = { 'prettier' },
        css = { 'prettier' },
        scss = { 'prettier' },
        html = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        lua = { 'stylua' },
        dart = { 'dartfmt' },
      },
      format_on_save = {
        enabled = true,
        async = false,
        timeout = 1000,
      },
    })

    vim.keymap.set(
      { 'n', 'v' },
      '<leader>cf',
      function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout = 1000,
        })
      end
    )
  end
}
