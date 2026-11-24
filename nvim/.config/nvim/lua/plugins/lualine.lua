vim.pack.add({
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
})

local red = require('catppuccin.palettes').get_palette('mocha').red

-- cmdheight=0 hides the built-in recording message.
local function recording()
  local reg = vim.fn.reg_recording()
  return reg ~= '' and '󰑊 @' .. reg or ''
end

vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
  callback = function()
    -- reg_recording() is still set during RecordingLeave.
    vim.schedule(function() require('lualine').refresh() end)
  end,
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
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { { recording, color = { fg = red } } },
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
})
