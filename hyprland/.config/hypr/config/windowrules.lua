-- Order matters: when two rules set the same property, the last one wins.

-- Tags

local tags = {
  { "terminal", { [[^(kitty)$]] } },
  { "browser", { [[^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$]] } },
  { "projects", { [[^(code|code-url-handler)$]] } },
  { "file-manager", { [[^([Tt]hunar)$]] } },
  { "im", { [[^([Vv]esktop)$]], [[^(teams-for-linux)$]] } },
  { "games", { [[^(gamescope)$]], [[^(steam_app_\d+)$]] } },
  { "gamestore", { [[^([Ss]team)$]] } },
  {
    "settings",
    {
      [[^([Rr]ofi)$]],
      [[^(file-roller|org.gnome.FileRoller)$]],
      [[^(nm-connection-editor)$]],
      [[^(qt5ct|qt6ct)$]],
      [[(xdg-desktop-portal-gtk)]],
    },
  },
}

for _, entry in ipairs(tags) do
  local tag, classes = entry[1], entry[2]
  for i, class in ipairs(classes) do
    hl.window_rule({
      name = ("tag-%s-%d"):format(tag, i),
      match = { class = class },
      tag = "+" .. tag,
    })
  end
end

-- Placement, floating and sizing

local steam = [[^([Ss]team)$]]
local steam_main = [[^([Ss]team|Friends List)$]]

hl.window_rule({
  name = "steam-to-scratchpad",
  match = { class = steam, title = steam_main },
  workspace = "special:gamestore",
})

hl.window_rule({
  name = "settings-float",
  match = { tag = "settings*" },
  float = true,
  size = "70% 70%",
})

hl.window_rule({ name = "mpv-float", match = { class = [[^(mpv)$]] }, float = true })

hl.window_rule({
  name = "polkit-float",
  match = { title = [[^(Authentication Required)$]] },
  float = true,
  center = true,
})

-- Some toolkits only set the final title after mapping, so match both.
local file_chooser = [[^([Oo]pen|[Ss]ave|[Ss]elect|[Cc]hoose).*([Ff]iles?|[Ff]olders?).*$]]

for _, prop in ipairs({ "title", "initial_title" }) do
  hl.window_rule({
    name = "file-chooser-" .. prop,
    match = { [prop] = file_chooser },
    float = true,
    center = true,
    size = "70% 60%",
  })
end

hl.window_rule({
  name = "vscode-add-folder",
  match = { initial_title = [[(Add Folder to Workspace)]] },
  float = true,
  size = "70% 60%",
})

hl.window_rule({
  name = "download-prompt",
  match = { initial_title = [[(wants to save)]] },
  float = true,
})

local float_tui_names = { "wiremix", "impala", "bluetui", "hyprmoncfg" }
local float_tui_titles = "^(" .. table.concat(float_tui_names, "|") .. ")$"

hl.window_rule({
  name = "float-tui",
  match = { class = [[^(kitty)$]], title = float_tui_titles },
  float = true,
})

-- A size rule does not survive kitty asserting its own size, so do it on open.
local is_float_tui = {}
for _, name in ipairs(float_tui_names) do
  is_float_tui[name] = true
end

local FLOAT_TUI_FRACTION = 0.7

hl.on("window.open", function(win)
  if win.class ~= "kitty" or not is_float_tui[win.title] then
    return
  end

  local monitor = win.monitor
  if not monitor then
    return
  end

  local width, height = monitor.width, monitor.height
  if monitor.transform % 2 == 1 then -- pre-rotation dimensions
    width, height = height, width
  end

  local target = "address:" .. win.address
  hl.dispatch(hl.dsp.window.resize({
    x = math.floor(width / monitor.scale * FLOAT_TUI_FRACTION),
    y = math.floor(height / monitor.scale * FLOAT_TUI_FRACTION),
    relative = false,
    window = target,
  }))
  hl.dispatch(hl.dsp.window.center({ window = target }))
end)

-- Steam popups float; steam-friends-tile.sh places the tiled friends list.
hl.window_rule({
  name = "steam-popups-float",
  match = { class = steam, title = "negative:" .. steam_main },
  float = true,
  pin = true,
})

hl.window_rule({
  name = "steam-friends-tile",
  match = { class = steam, title = [[^(Friends List)$]] },
  tile = true,
})

local pip = [[^(Picture-in-Picture)$]]

hl.window_rule({
  name = "pip",
  match = { title = pip },
  float = true,
  pin = true,
  move = "72% 7%",
  keep_aspect_ratio = true,
})

-- Appearance

local opacities = {
  { "tag", "browser*", "1.0 1.0" },
  { "tag", "projects*", "0.9 0.9" },
  { "tag", "im*", "0.9 0.9" },
  { "tag", "terminal*", "0.9 0.9" },
  { "tag", "settings*", "0.9 0.9" },
  { "tag", "file-manager*", "0.9 0.8" },
  { "class", [[^(com.anthropic.Claude)$]], "0.9 0.9" },
  { "class", [[^(seahorse)$]], "0.9 0.9" }, -- gnome-keyring gui
}

for i, entry in ipairs(opacities) do
  local prop, value, opacity = entry[1], entry[2], entry[3]
  hl.window_rule({
    name = ("opacity-%d"):format(i),
    match = { [prop] = value },
    opacity = opacity,
  })
end

-- After the tag rules, so these win over terminal* and browser*.
hl.window_rule({
  name = "float-tui-opacity",
  match = { class = [[^(kitty)$]], title = float_tui_titles },
  opacity = "0.95 0.95",
})

hl.window_rule({ name = "pip-opacity", match = { title = pip }, opacity = "1.0 1.0" })

hl.window_rule({
  name = "games",
  match = { tag = "games*" },
  fullscreen = true,
  no_blur = true,
})

hl.window_rule({
  name = "fullscreen-idle-inhibit",
  match = { fullscreen = true },
  idle_inhibit = "fullscreen",
})
