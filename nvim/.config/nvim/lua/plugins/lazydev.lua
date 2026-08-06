-- Must load after plugins.lspconfig: it only patches servers vim.lsp.is_enabled() already reports as enabled.

vim.pack.add({
  { src = 'https://github.com/folke/lazydev.nvim' },
})

require('lazydev').setup({
  library = {
    -- word-triggered: only pulled into a buffer's workspace when it uses `Snacks`.
    { path = 'snacks.nvim', words = { 'Snacks' } },
  },
})
