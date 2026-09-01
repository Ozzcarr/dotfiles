vim.pack.add({
  { src = 'https://github.com/chomosuke/typst-preview.nvim', version = vim.version.range('1') },
})

require('typst-preview').setup({
  -- Reuse the tinymist mason installs for the LSP rather than downloading a second copy.
  dependencies_bin = { tinymist = 'tinymist' },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'typst',
  callback = function()
    vim.keymap.set('n', '<leader>cp', '<cmd>TypstPreviewToggle<CR>',
      { buffer = true, desc = 'Toggle Typst preview' })
    vim.keymap.set('n', '<leader>ce', '<cmd>!tinymist compile % %:r.pdf<CR>',
      { buffer = true, desc = 'Compile Typst to PDF' })
  end,
})
