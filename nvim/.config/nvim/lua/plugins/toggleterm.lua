vim.pack.add({
  { src = 'https://github.com/akinsho/toggleterm.nvim' },
})

local mauve = require('catppuccin.palettes').get_palette('mocha').mauve

require('toggleterm').setup({
  open_mapping = [[<C-t>]],
  insert_mappings = true,
  direction = 'float',
  terminal_mappings = true,
  float_opts = {
    border = 'curved',
  },
  highlights = {
    FloatBorder = {
      guifg = mauve,
    },
  },
})

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*toggleterm#*',
  callback = function()
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = true, desc = 'Exit terminal mode' })
  end,
})
