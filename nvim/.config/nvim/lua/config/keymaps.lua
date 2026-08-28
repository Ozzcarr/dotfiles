local map = vim.keymap.set

-- Search
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Windows
map('n', '<leader>|', '<cmd>vsplit<CR>', { desc = 'Split window right' })
map('n', '<leader>-', '<cmd>split<CR>', { desc = 'Split window below' })
map('n', '<leader>wd', '<cmd>close<CR>', { desc = 'Close window' })
map('n', '<leader>wo', '<cmd>only<CR>', { desc = 'Close other windows' })
map('n', '<leader>w=', '<C-w>=', { desc = 'Equalize windows' })

-- Buffers
map('n', '<leader>bd', function() require('mini.bufremove').delete(0, false) end, { desc = 'Close buffer' })
map('n', '<leader>bo', function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      require('mini.bufremove').delete(buf, false)
    end
  end
end, { desc = 'Close other buffers' })

local resize = require('utils.window').resize
map({ 'n', 't' }, '<C-Left>', resize('left'), { desc = 'Move divider left' })
map({ 'n', 't' }, '<C-Down>', resize('down'), { desc = 'Move divider down' })
map({ 'n', 't' }, '<C-Up>', resize('up'), { desc = 'Move divider up' })
map({ 'n', 't' }, '<C-Right>', resize('right'), { desc = 'Move divider right' })

-- Editing
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Diagnostics
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next diagnostic' })
map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous diagnostic' })
map('n', ']e', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
  { desc = 'Next error' })
map('n', '[e', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end,
  { desc = 'Previous error' })
map('n', ']w', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN }) end,
  { desc = 'Next warning' })
map('n', '[w', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN }) end,
  { desc = 'Previous warning' })

-- LSP
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
map('n', '<leader>cf', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
  { desc = 'Format' })
map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
map('n', '<leader>cr', function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
  { expr = true, desc = 'Rename symbol' })
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
map('n', '<leader>uL', function() vim.wo.relativenumber = not vim.wo.relativenumber end,
  { desc = 'Toggle relative line numbers' })
map('n', '<leader>us', function() vim.wo.spell = not vim.wo.spell end, { desc = 'Toggle spell check' })
map('n', '<leader>uw', function() vim.wo.wrap = not vim.wo.wrap end, { desc = 'Toggle word wrap' })
map('n', '<leader>ui', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  { desc = 'Toggle inlay hints' })
