vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
})

require('mason-registry').refresh(function()
  if not require('mason-registry').is_installed('lua-language-server') then
    require('mason-registry').get_package('lua-language-server'):install()
  end
end)

vim.lsp.enable('lua_ls')
vim.lsp.enable('nixd')
