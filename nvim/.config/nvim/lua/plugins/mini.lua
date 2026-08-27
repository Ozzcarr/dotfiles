vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim' },
})

require('mini.icons').setup()
require('mini.ai').setup({})
require('mini.pairs').setup()
require('mini.surround').setup({
  mappings = {
    add = 'gsa',
    delete = 'gsd',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    replace = 'gsr',
    update_n_lines = 'gsn',
  },
})
