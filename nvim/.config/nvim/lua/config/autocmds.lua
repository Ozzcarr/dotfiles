vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

vim.api.nvim_create_autocmd('BufReadCmd', {
  group = vim.api.nvim_create_augroup('open-pdf-externally', { clear = true }),
  pattern = '*.pdf',
  callback = function(args)
    if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
      local cmd = '[workspace current] firefox --new-window ' .. vim.fn.shellescape(args.file)
      vim.fn.jobstart({ 'hyprctl', 'dispatch', 'exec', cmd }, { detach = true })
    else
      vim.fn.jobstart({ 'xdg-open', args.file }, { detach = true })
    end
    vim.schedule(function()
      vim.cmd.bwipeout({ args.buf, bang = true })
    end)
  end,
})
