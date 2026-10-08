-- SUPER goes to or opens things, SHIFT takes the window along (or is the
-- stronger variant), CTRL reshapes, ALT is system. Every bind carries a
-- description, which is what the cheatsheet lists.

local mod = "SUPER"

local terminal = "kitty"

local function bind(keys, action, description, opts)
  opts = opts or {}
  opts.description = description
  hl.bind(keys, action, opts)
end

local function exec(cmd)
  return hl.dsp.exec_cmd(cmd)
end

local function launcher(mode)
  return exec("qs -c oz ipc call launcher toggle " .. mode)
end

local function float_tui(tool)
  return exec(("%s --title %s -e %s"):format(terminal, tool, tool))
end

-- Jumps to the most recently used window of the class, or launches it.
local function focus_or_launch(class, cmd)
  return function()
    local best
    for _, w in ipairs(hl.get_windows()) do
      if w.class:lower() == class and (not best or w.focus_history_id < best.focus_history_id) then
        best = w
      end
    end
    if best then
      hl.dispatch(hl.dsp.focus({ window = "address:" .. best.address }))
    else
      hl.dispatch(exec(cmd))
    end
  end
end

-- Apps

bind(mod .. " + Return", exec(terminal), "Terminal")
bind(mod .. " + SPACE", launcher("apps"), "Launcher")

bind(mod .. " + W", focus_or_launch("firefox", "firefox"), "Firefox")
bind(mod .. " + SHIFT + W", exec("firefox --private-window"), "Private Firefox window")
bind(mod .. " + CTRL + W", exec("firefox --new-window"), "New Firefox window")
bind(mod .. " + E", focus_or_launch("code", "code"), "Editor")
bind(mod .. " + CTRL + E", exec("code --new-window"), "New editor window")
bind(mod .. " + T", focus_or_launch("thunar", "thunar"), "Files")
bind(mod .. " + CTRL + T", exec("thunar"), "New files window")
bind(mod .. " + D", focus_or_launch("vesktop", "vesktop"), "Vesktop")
bind(mod .. " + Y", exec(terminal .. " -e yazi"), "yazi")

-- Shell

bind(mod .. " + Tab", exec("qs -c oz ipc call dashboard toggle"), "Dashboard")
bind(mod .. " + N", exec("qs -c oz ipc call notifications toggle"), "Notification center")
bind(mod .. " + SHIFT + N", exec("qs -c oz ipc call notifications clear"), "Dismiss all notifications")
bind(mod .. " + CTRL + N", exec("qs -c oz ipc call notifications dnd"), "Do not disturb")
bind(mod .. " + V", launcher("clipboard"), "Clipboard history")
bind(mod .. " + C", exec("hyprpicker -a"), "Color picker")
bind(mod .. " + B", exec("qs -c oz ipc call wallpaper toggle"), "Wallpaper")

bind(mod .. " + S", exec("hyprshot -m region -o $HOME/Pictures/Screenshots"), "Screenshot a region")
bind(mod .. " + SHIFT + S", exec("hyprshot -m region --clipboard-only"), "Screenshot a region to the clipboard")

-- System

bind(mod .. " + ALT + S", exec("qs -c oz ipc call settings toggle"), "Quick settings")
bind(mod .. " + ALT + A", exec("qs -c oz ipc call settings open audio"), "Sound settings")
bind(mod .. " + ALT + W", exec("qs -c oz ipc call settings open wifi"), "Wi-Fi settings")
bind(mod .. " + ALT + B", exec("qs -c oz ipc call settings open bluetooth"), "Bluetooth settings")
bind(mod .. " + ALT + D", float_tui("hyprmoncfg"), "Displays")
bind(mod .. " + ALT + U", exec("qs -c oz ipc call nix toggle"), "NixOS: rebuild, update and generations")

bind(mod .. " + ALT + M", exec("vesktop-mute"), "Vesktop: mute mic")
bind(mod .. " + ALT + SHIFT + M", exec("vesktop-deafen"), "Vesktop: deafen")
bind(mod .. " + ALT + G", exec("vesktop-stream"), "Vesktop: stream the game")
bind(mod .. " + ALT + N", exec("qs -c oz ipc call nightlight toggle"), "Night light")
bind(mod .. " + ALT + V", exec("noise-mode toggle"), "Noise mode")
bind(mod .. " + ALT + I", exec("qs -c oz ipc call idle keepawake"), "Keep awake")
bind(mod .. " + ALT + SPACE", launcher("system"), "System menu")
bind(mod .. " + ALT + K", launcher("binds"), "Keybind cheatsheet")
bind(mod .. " + ALT + R", exec("qs -c oz ipc call shell reload"), "Reload shell")

bind(mod .. " + ALT + L", exec("qs -c oz ipc call lock lock"), "Lock")
bind(mod .. " + ALT + P", exec("qs -c oz ipc call session toggle"), "Session menu")

-- Windows

bind(mod .. " + Q", hl.dsp.window.close(), "Close window")
bind(mod .. " + SHIFT + Q", exec([[hyprctl activewindow | awk '$1=="pid:"{print $2}' | xargs -r kill]]), "Kill window")

bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }), "Fullscreen")
bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(mod .. " + CTRL + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }), "Maximize")
bind(mod .. " + I", hl.dsp.layout("togglesplit"), "Toggle split")
bind(mod .. " + P", hl.dsp.window.pin({ action = "toggle" }), "Pin floating window")

bind(mod .. " + mouse:272", hl.dsp.window.drag(), "Move window", { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })
bind(mod .. " + mouse:274", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")

-- Swap is bound by keycode so it survives a layout change.
local directions = {
  { name = "left", key = "h", code = 43, arrow = "left", resize = { -40, 0 } },
  { name = "down", key = "j", code = 44, arrow = "down", resize = { 0, 40 } },
  { name = "up", key = "k", code = 45, arrow = "up", resize = { 0, -40 } },
  { name = "right", key = "l", code = 46, arrow = "right", resize = { 40, 0 } },
}

for _, d in ipairs(directions) do
  bind(mod .. " + " .. d.key, hl.dsp.focus({ direction = d.name }), "Focus " .. d.name)
  bind(
    mod .. " + " .. d.arrow,
    hl.dsp.window.resize({ x = d.resize[1], y = d.resize[2], relative = true }),
    "Resize window " .. d.name,
    { repeating = true }
  )

  for _, key in ipairs({ d.key, d.arrow }) do
    bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = d.name }), "Move window " .. d.name)
  end

  bind(mod .. " + CTRL + code:" .. d.code, hl.dsp.window.swap({ direction = d.name }), "Swap window " .. d.name)
  bind(mod .. " + CTRL + " .. d.arrow, hl.dsp.window.swap({ direction = d.name }), "Swap window " .. d.name)
end

-- Workspaces

for i = 1, 10 do
  local key = i % 10 -- 10 sits on the 0 key
  bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Workspace " .. i)
  bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
end

bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")

local scratchpads = {
  { key = "M", name = "spotify", label = "Spotify" },
  { key = "G", name = "gamestore", label = "Game store" },
}

for _, s in ipairs(scratchpads) do
  bind(mod .. " + " .. s.key, hl.dsp.workspace.toggle_special(s.name), s.label .. " scratchpad")
  bind(
    mod .. " + SHIFT + " .. s.key,
    hl.dsp.window.move({ workspace = "special:" .. s.name, follow = false }),
    "Move window to " .. s.label .. " scratchpad"
  )
end

-- Wooting UwU
bind("code:191", exec("vesktop-mute"), "Vesktop: mute mic")
bind("code:192", exec("vesktop-deafen"), "Vesktop: deafen")
bind("code:193", exec("vesktop-stream"), "Vesktop: stream the game")
bind("code:194", exec("noise-mode toggle"), "Noise mode")
bind("code:199", exec("obs-replay save"), "OBS: save replay")

-- Media and hardware keys

local media = { locked = true }
local held = { locked = true, repeating = true }

bind("XF86AudioRaiseVolume", exec("qs -c oz ipc call audio up"), "Volume up", held)
bind("XF86AudioLowerVolume", exec("qs -c oz ipc call audio down"), "Volume down", held)
bind("XF86AudioMute", exec("qs -c oz ipc call audio mute"), "Mute", media)
bind(mod .. " + XF86AudioRaiseVolume", exec("playerctl --player=spotify volume 0.05+"), "Spotify volume up", held)
bind(mod .. " + XF86AudioLowerVolume", exec("playerctl --player=spotify volume 0.05-"), "Spotify volume down", held)

local players = "spotify,firefox"
bind("XF86AudioPlay", exec("playerctl --player=" .. players .. " play-pause"), "Play/pause", media)
bind("XF86AudioPause", exec("playerctl --player=" .. players .. " play-pause"), "Play/pause", media)
bind("XF86AudioNext", exec("playerctl --player=" .. players .. " next"), "Next track", media)
bind("XF86AudioPrev", exec("playerctl --player=" .. players .. " previous"), "Previous track", media)

bind("XF86MonBrightnessUp", exec("brightnessctl set +5% && qs -c oz ipc call osd brightness"), "Brightness up", held)
bind("XF86MonBrightnessDown", exec("brightnessctl set 5%- && qs -c oz ipc call osd brightness"), "Brightness down", held)
