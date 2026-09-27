hl.env("NIXPKGS_ALLOW_UNFREE", "1")

-- Toolkits
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("SDL_VIDEODRIVER", "x11")

-- Scaling is per-monitor, so keep the toolkits at 1x
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")

hl.env("TERMINAL", "kitty")
hl.env("XDG_TERMINAL_EMULATOR", "kitty")
