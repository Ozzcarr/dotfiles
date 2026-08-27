vim.pack.add({
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
})

require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local map = vim.keymap.set

    map('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gs.nav_hunk('next')
      end
    end, { buffer = bufnr, desc = 'Next hunk' })

    map('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gs.nav_hunk('prev')
      end
    end, { buffer = bufnr, desc = 'Previous hunk' })

    map('n', '<leader>gs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
    map('n', '<leader>gr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
    map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
      { buffer = bufnr, desc = 'Stage hunk' })
    map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
      { buffer = bufnr, desc = 'Reset hunk' })
    map('n', '<leader>gp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
  end,
})
