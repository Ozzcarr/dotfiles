vim.pack.add({
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
})

require('lualine').setup({
  options = {
    theme = 'catppuccin-mocha',
    globalstatus = true,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = { 'branch', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = {},
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
})
