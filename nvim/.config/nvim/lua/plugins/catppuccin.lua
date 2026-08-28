vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
})

require('catppuccin').setup({
  flavour = 'mocha',
  integrations = {
    rainbow_delimiters = true,
    blink_cmp = true,
  },
  lsp_styles = {
    inlay_hints = {
      background = false,
    },
  },
  custom_highlights = function(colors)
    return {
      ['@property.json'] = { fg = colors.blue },
      ['@property.yaml'] = { fg = colors.blue },
      ['@property.toml'] = { fg = colors.blue },
    }
  end,
})

vim.cmd.colorscheme('catppuccin')
