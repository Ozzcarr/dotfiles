vim.pack.add({
  { src = 'https://github.com/coder/claudecode.nvim' },
})

require('claudecode').setup()

local map = vim.keymap.set
map('n', '<leader>ac', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude' })
map('n', '<leader>af', '<cmd>ClaudeCodeFocus<CR>', { desc = 'Focus Claude' })
map('n', '<leader>ar', '<cmd>ClaudeCode --resume<CR>', { desc = 'Resume Claude' })
map('n', '<leader>aC', '<cmd>ClaudeCode --continue<CR>', { desc = 'Continue Claude' })
map('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<CR>', { desc = 'Select Claude model' })
map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<CR>', { desc = 'Add current buffer' })
map('x', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = 'Send selection to Claude' })
map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', { desc = 'Accept diff' })
map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', { desc = 'Deny diff' })

-- In a file explorer the same key adds the entry under the cursor instead.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'snacks_picker_list', 'netrw', 'oil', 'minifiles' },
  callback = function(args)
    map('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<CR>', { buffer = args.buf, desc = 'Add file to Claude' })
  end,
})
