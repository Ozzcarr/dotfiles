vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
})

require('treesitter-context').setup({
  max_lines = 8,
  multiline_threshold = 3,
  trim_scope = 'inner',
  separator = '─',
})

vim.keymap.set('n', '[c', function() require('treesitter-context').go_to_context(vim.v.count1) end,
  { silent = true, desc = 'Jump to context' })
