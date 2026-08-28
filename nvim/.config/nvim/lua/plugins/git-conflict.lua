vim.pack.add({
  { src = 'https://github.com/akinsho/git-conflict.nvim' },
})

require('git-conflict').setup()

vim.keymap.set('n', '<leader>gc', '<cmd>GitConflictListQf<CR>', { desc = 'List conflicts' })
