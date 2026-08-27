vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
})

require('mason-tool-installer').setup({
  ensure_installed = {
    'lua-language-server',
    'typescript-language-server',
    'ruff',
  },
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('nixd')
vim.lsp.enable('ts_ls')
vim.lsp.enable('ty')
