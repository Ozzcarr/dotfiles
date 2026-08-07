vim.pack.add({
  { src = 'https://github.com/mason-org/mason.nvim' },
})

require('mason').setup()

vim.keymap.set('n', '<leader>m', '<cmd>Mason<CR>', { desc = 'Mason' })
