vim.pack.add({
  { src = 'https://github.com/OXY2DEV/markview.nvim' },
})

require('markview').setup({
  preview = {
    icon_provider = 'mini',
  },
})
