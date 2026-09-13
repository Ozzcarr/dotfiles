vim.pack.add({
  { src = 'https://github.com/mfussenegger/nvim-lint' },
})

-- Prefer a project's own pinned ruff (uv/poetry dev dependency) over the global mason one.
local function resolve_ruff()
  local root = vim.fs.root(0, { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' })
  if root then
    for _, rel in ipairs({ '.venv/bin/ruff', 'venv/bin/ruff' }) do
      local candidate = root .. '/' .. rel
      if vim.uv.fs_stat(candidate) then
        return candidate
      end
    end
  end
  return 'ruff'
end

require('lint').linters.ruff =
    vim.tbl_extend('force', require('lint').linters.ruff --[[@as lint.Linter]], { cmd = resolve_ruff })

require('lint').linters_by_ft = {
  python = { 'ruff' },
}

-- Fresh ruff process per run means it never goes stale, unlike an LSP client.
-- FileType is included because BufReadPost can fire before the buffer's filetype is set, which would make try_lint() silently no-op.
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave', 'FileType' }, {
  callback = function()
    require('lint').try_lint()
  end,
})

-- try_lint() only lints the current buffer, so ruff config saves need an explicit nudge for other open Python buffers.
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'pyproject.toml', 'ruff.toml', '.ruff.toml' },
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'python' then
        vim.api.nvim_buf_call(buf, function()
          require('lint').try_lint()
        end)
      end
    end
  end,
})
