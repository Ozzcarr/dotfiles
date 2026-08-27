vim.g.tmux_navigator_no_mappings = 1

vim.pack.add({
  { src = 'https://github.com/christoomey/vim-tmux-navigator' },
})

local map = vim.keymap.set
local opts = { silent = true }

map('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', opts)
map('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', opts)
map('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', opts)
map('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', opts)
map('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<CR>', opts)

map('t', '<C-h>', [[<C-\><C-n>:TmuxNavigateLeft<CR>]], opts)
map('t', '<C-j>', [[<C-\><C-n>:TmuxNavigateDown<CR>]], opts)
map('t', '<C-k>', [[<C-\><C-n>:TmuxNavigateUp<CR>]], opts)
map('t', '<C-l>', [[<C-\><C-n>:TmuxNavigateRight<CR>]], opts)
