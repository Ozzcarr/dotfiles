-- Required as `config` from the home-manager-generated ~/.config/hypr/hyprland.lua.

require("config.env") -- before autostart, so spawned processes inherit it
require("config.looknfeel")
require("config.misc")
require("config.input")
require("config.binds")
require("config.windowrules")
require("config.workspaces")
require("config.autostart")
