local mod = "SUPER"
local hypr_dir = os.getenv("HOME") .. "/dotfiles/hyprland/.config/hypr"

local terminal = "kitty"
local browser = "firefox"
local editor = "code"
local file_manager = "thunar"
local launcher = [[rofi -show drun -modi "drun,calc" -calc-command "echo -n '{result}' | wl-copy"]]

local function exec(cmd)
  return hl.dsp.exec_cmd(cmd)
end

-- Without remember_window_size=no kitty flashes at its last size first.
local function float_tui(tool)
  return exec(("%s -o remember_window_size=no --title %s -e %s"):format(terminal, tool, tool))
end

local function screenshot(mode)
  return exec(("hyprshot -m %s -o $HOME/Pictures/Screenshots"):format(mode))
end

-- Applications

hl.bind(mod .. " + Return", exec(terminal))
hl.bind(mod .. " + SPACE", exec(launcher))
hl.bind(mod .. " + W", exec(browser))
hl.bind(mod .. " + SHIFT + W", exec(browser .. " --private-window"))
hl.bind(mod .. " + E", exec(editor))
hl.bind(mod .. " + T", exec(file_manager))
hl.bind(mod .. " + Y", exec(terminal .. " -e yazi"))
hl.bind(mod .. " + D", exec("vesktop"))

hl.bind(mod .. " + SHIFT + A", float_tui("wiremix"))
hl.bind(mod .. " + SHIFT + I", float_tui("impala"))
hl.bind(mod .. " + SHIFT + B", float_tui("bluetui"))
hl.bind(mod .. " + SHIFT + O", float_tui("hyprmoncfg"))

-- Session and utilities

hl.bind(mod .. " + escape", exec("hyprlock"))
hl.bind(mod .. " + SHIFT + escape", exec("wlogout"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exit())

hl.bind(mod .. " + N", exec("swaync-client -t -sw"))
hl.bind(mod .. " + SHIFT + N", exec(hypr_dir .. "/night-light.sh"))
hl.bind(mod .. " + B", exec("wallpaper"))
hl.bind(mod .. " + C", exec("hyprpicker -a"))
hl.bind(mod .. " + V", exec("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mod .. " + SHIFT + R", exec("pkill waybar; sleep .5; exec waybar"))

hl.bind(mod .. " + S", screenshot("region"))
hl.bind(mod .. " + SHIFT + S", screenshot("window"))
hl.bind(mod .. " + CTRL + S", screenshot("output"))

hl.bind(mod .. " + SHIFT + V", exec("noise-mode toggle"))

hl.bind(mod .. " + SHIFT + M", exec("vesktop-mute"))
hl.bind(mod .. " + SHIFT + D", exec("vesktop-deafen"))

-- Windows

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", exec([[hyprctl activewindow | awk '$1=="pid:"{print $2}' | xargs -r kill]]))

hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + I", hl.dsp.layout("togglesplit"))

hl.bind("ALT + Tab", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Swap is bound by keycode so it survives a layout change.
local directions = {
  { name = "left", key = "h", code = 43, arrow = "left", resize = { -60, 0 } },
  { name = "down", key = "j", code = 44, arrow = "down", resize = { 0, 60 } },
  { name = "up", key = "k", code = 45, arrow = "up", resize = { 0, -60 } },
  { name = "right", key = "l", code = 46, arrow = "right", resize = { 60, 0 } },
}

for _, d in ipairs(directions) do
  hl.bind(mod .. " + " .. d.key, hl.dsp.focus({ direction = d.name }))

  hl.bind(mod .. " + " .. d.arrow, hl.dsp.window.resize({ x = d.resize[1], y = d.resize[2], relative = true }))

  hl.bind(mod .. " + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.name }))
  hl.bind(mod .. " + SHIFT + " .. d.arrow, hl.dsp.window.move({ direction = d.name }))

  hl.bind(mod .. " + CTRL + code:" .. d.code, hl.dsp.window.swap({ direction = d.name }))
end

-- Only up/down; CTRL + left/right cycles workspaces below, and both would fire.
hl.bind(mod .. " + CTRL + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mod .. " + CTRL + down", hl.dsp.window.swap({ direction = "down" }))

-- Workspaces

for i = 1, 10 do
  local key = i % 10 -- 10 sits on the 0 key
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + CTRL + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + M", hl.dsp.workspace.toggle_special("spotify"))
hl.bind(mod .. " + O", hl.dsp.workspace.toggle_special("obs"))
hl.bind(mod .. " + G", hl.dsp.workspace.toggle_special("gamestore"))

-- Media and hardware keys

-- Volume drives Spotify's own volume; mute drives the sink.
hl.bind("XF86AudioRaiseVolume", exec("playerctl --player=spotify volume 0.05+"))
hl.bind("XF86AudioLowerVolume", exec("playerctl --player=spotify volume 0.05-"))
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

local players = "spotify,firefox"
hl.bind("XF86AudioPlay", exec("playerctl --player=" .. players .. " play-pause"))
hl.bind("XF86AudioPause", exec("playerctl --player=" .. players .. " play-pause"))
hl.bind("XF86AudioNext", exec("playerctl --player=" .. players .. " next"))
hl.bind("XF86AudioPrev", exec("playerctl --player=" .. players .. " previous"))

hl.bind("XF86MonBrightnessUp", exec("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"))
