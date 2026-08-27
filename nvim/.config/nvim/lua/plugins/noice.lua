vim.pack.add({
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
  { src = 'https://github.com/folke/noice.nvim' },
})

require('noice').setup({
  presets = { inc_rename = true },
  cmdline = {
    view = 'cmdline_popup',
  },
  messages = { enabled = false },
  popupmenu = { enabled = false },
  notify = { enabled = false },
  lsp = {
    progress = { enabled = false },
    hover = { enabled = false },
    signature = { enabled = false },
    message = { enabled = false },
  },
})
