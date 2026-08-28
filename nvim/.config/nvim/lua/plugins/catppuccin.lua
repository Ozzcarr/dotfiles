vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
})

require('catppuccin').setup({
  flavour = 'mocha',
  integrations = {
    rainbow_delimiters = true,
    blink_cmp = true,
  },
  lsp_styles = {
    inlay_hints = {
      background = false,
    },
  },
})

vim.cmd.colorscheme('catppuccin')
