local hypr_dir = os.getenv("HOME") .. "/dotfiles/hyprland/.config/hypr"

local function restart(process, cmd)
  hl.exec_cmd(("pkill %s; sleep .5; exec %s"):format(process, cmd or process))
end

hl.on("hyprland.start", function()
  -- home-manager's own start hook imports five variables; this adds the rest
  hl.exec_cmd("dbus-update-activation-environment --all --systemd")

  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  hl.exec_cmd("systemctl --user start hyprpolkitagent")

  restart("awww-daemon")

  hl.exec_cmd(hypr_dir .. "/steam-friends-tile.sh")

  -- XWayland has no primary output, so X11 games all land on output 0.
  hl.exec_cmd("$HOME/.local/bin/set-primary-monitor DP-1")

  hl.exec_cmd("sleep 1.0 && wallpaper restore")
end)
