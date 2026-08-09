vim.pack.add({
  { src = 'https://github.com/folke/which-key.nvim' },
})

require('which-key').setup({
  preset = 'modern',
  delay = 500,
})

require('which-key').add({
  { '<leader>c', group = 'Code' },
  { '<leader>d', group = 'Docker', icon = { icon = '󰡨', color = 'blue' } },
  { '<leader>f', group = 'Find' },
  { '<leader>g', group = 'Git' },
  { '<leader>m', desc = 'Mason', icon = { icon = '', color = 'orange' } },
  { '<leader>t', desc = 'Terminal' },
  { '<leader>w', group = 'Window' },
})
