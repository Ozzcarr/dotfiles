vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
})

local parsers = {
  'lua',
  'nix',
  'typescript',
  'tsx',
  'python',
  'markdown',
  'markdown_inline',
  'json',
  'yaml',
  'toml',
  'dockerfile',
  'bash',
  'gitignore',
  'git_config',
  'gitcommit',
  'diff',
}

require('nvim-treesitter').install(parsers)

vim.schedule(function()
  local filetypes = {}
  for _, parser in ipairs(parsers) do
    vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(parser))
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    callback = function()
      vim.treesitter.start()
    end,
  })

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
      vim.treesitter.start(buf)
    end
  end
end)
