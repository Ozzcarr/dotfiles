vim.pack.add({
  { src = 'https://github.com/folke/snacks.nvim' },
})

require('snacks').setup({
  picker = {
    sources = {
      explorer = { hidden = true },
      files = { hidden = true },
      grep = { hidden = true },
    },
  },
  dashboard = {
    sections = {
      { section = 'header' },
      { section = 'keys',  gap = 1, padding = 1 },
      {
        pane = 2,
        section = 'terminal',
        cmd = 'colorscript -e square',
        height = 5,
        padding = 1,
      },

      { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
      {
        pane = 2,
        icon = ' ',
        title = 'Git Status',
        section = 'terminal',
        enabled = function()
          return Snacks.git.get_root() ~= nil
        end,
        cmd = 'git status --short --branch --renames',
        height = 5,
        padding = 1,
        ttl = 5 * 60,
        indent = 3,
      },
      { section = 'pack_startup' },
    },
  },
  bigfile = {},
  indent = {},
  input = {},
  notifier = {},
  statuscolumn = {},
  words = {},
  explorer = {},
  scratch = {},
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
map('n', '<leader>gb', function() Snacks.git.blame_line() end, { desc = 'Git blame line' })
map('n', '<leader>.', function() Snacks.scratch() end, { desc = 'Toggle scratch buffer' })
map('n', '<leader>S', function() Snacks.scratch.select() end, { desc = 'Select scratch buffer' })
map('n', '<leader>t', function()
  Snacks.scratch({ ft = 'markdown', name = 'Todo', filekey = { cwd = false, branch = false, count = false } })
end, { desc = 'Todo scratch' })

Snacks.dashboard.sections.pack_startup = function()
  local ms = math.floor((vim.uv.hrtime() - _G.nvim_start_time) / 1e6 * 100 + 0.5) / 100
  local plugins = vim.pack.get()
  local loaded = 0
  for _, plugin in ipairs(plugins) do
    if plugin.active then
      loaded = loaded + 1
    end
  end
  return {
    align = 'center',
    text = {
      { '⚡ Neovim loaded ', hl = 'footer' },
      { loaded .. '/' .. #plugins, hl = 'special' },
      { ' plugins in ', hl = 'footer' },
      { ms .. 'ms', hl = 'special' },
    },
  }
end
