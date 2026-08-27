local map = vim.keymap.set

-- Search
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Windows
map('n', '<leader>|', '<cmd>vsplit<CR>', { desc = 'Split window right' })
map('n', '<leader>-', '<cmd>split<CR>', { desc = 'Split window below' })
map('n', '<leader>wd', '<cmd>close<CR>', { desc = 'Close window' })
map('n', '<leader>wo', '<cmd>only<CR>', { desc = 'Close other windows' })
map('n', '<leader>w=', '<C-w>=', { desc = 'Equalize windows' })

local resize = require('utils.window').resize
map('n', '<C-Left>', resize('left'), { desc = 'Move divider left' })
map('n', '<C-Down>', resize('down'), { desc = 'Move divider down' })
map('n', '<C-Up>', resize('up'), { desc = 'Move divider up' })
map('n', '<C-Right>', resize('right'), { desc = 'Move divider right' })

-- Editing
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Diagnostics
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

-- LSP
map('n', '<leader>cf', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end, { desc = 'Format' })
map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
map('n', '<leader>co', function()
  vim.lsp.buf.code_action({
    context = { only = { 'source.organizeImports' }, diagnostics = {} },
    apply = true,
  })
end, { desc = 'Organize imports' })

-- Files
map({ 'n', 'i', 'v' }, '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })

-- Neovim
map('n', '<leader>wr', '<cmd>restart<CR>', { desc = 'Reload Neovim' })

-- UI
map('n', '<leader>uc', function() vim.wo.cursorline = not vim.wo.cursorline end, { desc = 'Toggle cursorline' })
map('n', '<leader>ul', function() vim.wo.number = not vim.wo.number end, { desc = 'Toggle line numbers' })
map('n', '<leader>uL', function() vim.wo.relativenumber = not vim.wo.relativenumber end, { desc = 'Toggle relative line numbers' })
map('n', '<leader>us', function() vim.wo.spell = not vim.wo.spell end, { desc = 'Toggle spell check' })
map('n', '<leader>uw', function() vim.wo.wrap = not vim.wo.wrap end, { desc = 'Toggle word wrap' })
