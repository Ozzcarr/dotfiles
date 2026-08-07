vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim' },
})

require('mini.icons').setup()
require('mini.ai').setup({})
require('mini.surround').setup({
  mappings = {
    add = 'ys',
    delete = 'ds',
    find = '',
    find_left = '',
    highlight = '',
    replace = 'cs',
    suffix_last = '',
    suffix_next = '',
  },
  search_method = 'cover_or_next',
})

vim.keymap.del('x', 'ys')
vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
vim.keymap.set('n', 'yss', 'ys_', { remap = true })
