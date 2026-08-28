vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
})

require('mason-tool-installer').setup({
  ensure_installed = {
    'lua-language-server',
    'typescript-language-server',
    'ruff',
    'json-lsp',
    'yaml-language-server',
    'bash-language-server',
    'dockerfile-language-server',
    'docker-compose-language-service',
    'taplo',
    'shfmt',
  },
})

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('nixd')
vim.lsp.enable('ts_ls')
vim.lsp.enable('ty')
vim.lsp.enable('jsonls')
vim.lsp.enable('yamlls')
vim.lsp.enable('bashls')
vim.lsp.enable('dockerls')
vim.lsp.enable('docker_compose_language_service')
vim.lsp.enable('taplo')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})
