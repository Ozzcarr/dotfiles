vim.pack.add({
  { src = 'https://github.com/stevearc/conform.nvim' },
})

require('conform').setup({
  formatters_by_ft = {
    json = { 'prettierd' },
    jsonc = { 'prettierd' },
    javascript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    typescript = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    css = { 'prettierd' },
    html = { 'prettierd' },
    markdown = { 'prettierd' },
    yaml = { 'prettierd' },
    python = { 'ruff_format' },
    toml = { 'taplo' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
  },
})
