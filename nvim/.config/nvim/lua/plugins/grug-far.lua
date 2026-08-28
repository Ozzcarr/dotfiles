vim.pack.add({
  { src = 'https://github.com/MagicDuck/grug-far.nvim' },
})

require('grug-far').setup()

vim.keymap.set('n', '<leader>fR', '<cmd>GrugFar<CR>', { desc = 'Find and replace' })
