local M = {}

--- Build a handler that moves the divider in `dir` ('left', 'right', 'up', 'down').
---
--- The direction describes which way the boundary moves, not whether this
--- window gets bigger, so the same key grows or shrinks depending on which
--- side of that divider the window sits on. tmux binds the same keys with the
--- same semantics; when there is no split on the relevant axis to move, the
--- resize is handed back out to tmux so it can move its own pane divider.
function M.resize(dir)
  local horizontal = dir == 'left' or dir == 'right'
  local near = horizontal and 'h' or 'k'
  local far = horizontal and 'l' or 'j'
  local pane = ({ left = '-L', right = '-R', up = '-U', down = '-D' })[dir]

  return function()
    local cur = vim.fn.winnr()
    local has_near = vim.fn.winnr(near) ~= cur

    if not has_near and vim.fn.winnr(far) == cur then
      if vim.env.TMUX then
        vim.system({ 'tmux', 'resize-pane', pane, '2' })
      end
      return
    end

    -- Moving the divider toward the side it sits on grows this window.
    local grow = has_near == (dir == 'left' or dir == 'up')
    vim.cmd((horizontal and 'vertical resize ' or 'resize ') .. (grow and '+2' or '-2'))
  end
end

return M
