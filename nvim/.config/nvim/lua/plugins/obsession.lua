vim.pack.add({
  { src = 'https://github.com/tpope/vim-obsession' },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('obsession-autostart', { clear = true }),
  callback = function()
    if vim.fn.argc() > 0 and vim.fn.exists(':Obsession') == 2 then
      vim.cmd('Obsession')
    end
  end,
})
