vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
})

local parsers = {
  'lua',
  'nix',
}

require('nvim-treesitter').install(parsers)

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
