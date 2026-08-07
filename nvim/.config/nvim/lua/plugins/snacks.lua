vim.pack.add({
  { src = 'https://github.com/folke/snacks.nvim' },
})

require('snacks').setup({
  picker = {
    sources = {
      explorer = { hidden = true },
    },
  },
  dashboard = {
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { section = 'recent_files', padding = 1 },
    },
  },
  bigfile = {},
  indent = {},
  input = {},
  notifier = {},
  statuscolumn = {},
  words = {},
  explorer = {},
})

local map = vim.keymap.set
map('n', '<leader>dd', function() Snacks.terminal({ 'lazydocker' }) end, { desc = 'Lazydocker' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Find buffers' })
map('n', '<leader>fe', function() Snacks.explorer() end, { desc = 'Explorer' })
map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Find files' })
map('n', '<leader>fg', function() Snacks.picker.grep() end, { desc = 'Live grep' })
map('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Recent files' })
map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazygit' })
map('n', '<leader>gl', function() Snacks.lazygit.log_file() end, { desc = 'Lazygit Log (cwd)' })
