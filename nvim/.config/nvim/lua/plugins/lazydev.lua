-- Must load after plugins.lspconfig: it only patches servers vim.lsp.is_enabled() already reports as enabled.

vim.pack.add({
  { src = 'https://github.com/folke/lazydev.nvim' },
})

require('lazydev').setup()
