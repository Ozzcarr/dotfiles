vim.pack.add({
  { src = 'https://github.com/coder/claudecode.nvim' },
})

require('claudecode').setup()

local profiles = {
  personal = {},
  work = { CLAUDE_CONFIG_DIR = vim.fn.expand('~/.claude-work') },
}
local profile = 'personal'

-- The env is only applied when the Claude process starts, so the running
-- session has to be closed for the switch to take effect.
local function set_profile(name)
  if not profiles[name] then
    vim.notify('Unknown Claude profile: ' .. name, vim.log.levels.ERROR)
    return
  end
  local terminal = require('claudecode.terminal')
  terminal.close()
  terminal.setup(nil, nil, profiles[name])
  profile = name
  vim.notify('Claude profile: ' .. name)
end

vim.api.nvim_create_user_command('ClaudeProfile', function(opts)
  if opts.args == '' then
    vim.notify('Claude profile: ' .. profile)
  else
    set_profile(opts.args)
  end
end, {
  nargs = '?',
  complete = function()
    return vim.tbl_keys(profiles)
  end,
})

local map = vim.keymap.set
map('n', '<leader>ap', function()
  set_profile(profile == 'personal' and 'work' or 'personal')
end, { desc = 'Switch Claude profile' })
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
