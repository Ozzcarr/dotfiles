-- vim.pack has no ordering primitives, so load order is list order.
-- Colorscheme first: anything that reads highlight groups must come after it.

require('plugins.catppuccin')
require('plugins.treesitter')
require('plugins.mason')
require('plugins.lspconfig')
require('plugins.lazydev')
require('plugins.snacks')
