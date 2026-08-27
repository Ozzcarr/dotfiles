vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
})

require('todo-comments').setup()

local map = vim.keymap.set
map('n', ']t', function() require('todo-comments').jump_next() end, { desc = 'Next todo comment' })
map('n', '[t', function() require('todo-comments').jump_prev() end, { desc = 'Previous todo comment' })
map('n', '<leader>xt', '<cmd>Trouble todo toggle<CR>', { desc = 'Todos' })
