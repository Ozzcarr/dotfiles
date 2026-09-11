-- Snacks' explorer gets its icons from mini.icons, which only ships folder
-- icons for home and system directories -- every project folder (data/,
-- scripts/, reports/, ...) falls back to one generic glyph. real-icons draws
-- VSCode's Material Icon Theme as real images through kitty's graphics
-- protocol instead, so the whole icon set comes from the theme rather than a
-- hand-maintained table. Needs `allow-passthrough on` when running in tmux;
-- outside kitty it quietly falls back to the mini.icons glyphs.

-- The icon pack is downloaded at runtime, so fetch it whenever the plugin
-- itself is installed or updated. Registered before `add()` so it also fires
-- on the very first install.
local fetch_pack = false
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'real-icons.nvim' and ev.data.kind ~= 'delete' then
      fetch_pack = true
    end
  end,
})

vim.pack.add({
  { src = 'https://github.com/Mirsmog/real-icons.nvim' },
})

require('real-icons').setup({
  integrations = { snacks_picker = true },
})

if fetch_pack then
  vim.schedule(function() vim.cmd('RealIcons install') end)
end
