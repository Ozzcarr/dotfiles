vim.pack.add({
  { src = 'https://github.com/catgoose/nvim-colorizer.lua' },
})

require('colorizer').setup({
  options = {
    parsers = { names = { enable = false } },
  },
})
