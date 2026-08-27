vim.pack.add({
  { src = 'https://github.com/folke/trouble.nvim' },
})

require('trouble').setup()

local map = vim.keymap.set
map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics' })
map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer diagnostics' })
map('n', '<leader>xL', '<cmd>Trouble loclist toggle<CR>', { desc = 'Location list' })
map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix list' })
