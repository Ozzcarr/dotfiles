_G.nvim_start_time = vim.uv.hrtime()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('plugins')
require('config.keymaps')
require('config.autocmds')
