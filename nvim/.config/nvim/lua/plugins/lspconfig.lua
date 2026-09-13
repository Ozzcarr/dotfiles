vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
})

require('mason-tool-installer').setup({
  ensure_installed = {
    'lua-language-server',
    'typescript-language-server',
    'ruff',
    'ty',
    'json-lsp',
    'yaml-language-server',
    'bash-language-server',
    'dockerfile-language-server',
    'docker-compose-language-service',
    'taplo',
    'tinymist',
    'shfmt',
    'typstyle',
  },
})

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- nixd resolves packages only under the names `pkgs` and `lib`, against this
-- expression. Pointing it at the flake gives hovers the pinned versions.
vim.lsp.config('nixd', {
  settings = {
    nixd = {
      nixpkgs = {
        expr = '(builtins.getFlake "/home/oscar/nix-config").legacyPackages.x86_64-linux',
      },
    },
  },
})

-- nvim-lint owns Python diagnostics. Ruff's LSP stays only for <leader>co's organize-imports action, with its own diagnostics off so they don't compete.
vim.lsp.config('ruff', {
  -- Ruff reads settings from init_options, not the regular `settings` field.
  init_options = {
    settings = {
      lint = { enable = false },
    },
  },
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('nixd')
vim.lsp.enable('ts_ls')
vim.lsp.enable('ty')
vim.lsp.enable('ruff')
vim.lsp.enable('jsonls')
vim.lsp.enable('yamlls')
vim.lsp.enable('bashls')
vim.lsp.enable('dockerls')
vim.lsp.enable('docker_compose_language_service')
vim.lsp.enable('taplo')
vim.lsp.enable('tinymist')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

-- ruff doesn't pick up pyproject.toml/ruff.toml edits on its own, hence the restart.
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'pyproject.toml', 'ruff.toml', '.ruff.toml' },
  callback = function()
    if #vim.lsp.get_clients({ name = 'ruff' }) > 0 then
      vim.cmd('lsp restart ruff')
    end
  end,
})
