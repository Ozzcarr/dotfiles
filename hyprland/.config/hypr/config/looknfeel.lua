local scheme = require("generated.scheme")

-- Mirrored in quickshell/.config/quickshell/oz/config/Tokens.qml (marked SHARED).
local frame = {
  thickness = 4,
  pod = 26,
  gap = 6,
  window_radius = 14,
}

local function rgb(hex)
  return ("rgb(%s)"):format(hex:sub(2))
end

local function rgba(hex, alpha)
  return ("rgba(%s%02x)"):format(hex:sub(2), math.floor(alpha * 255 + 0.5))
end

hl.config({
  general = {
    layout = "dwindle",

    -- The shell's frame is drawn inside gaps_out.
    gaps_in = frame.gap / 2,
    gaps_out = {
      top = frame.pod + frame.gap,
      right = frame.thickness + frame.gap,
      bottom = frame.thickness + frame.gap,
      left = frame.thickness + frame.gap,
    },

    border_size = 2,

    -- The shell replaces active_border with the wallpaper accent at runtime.
    col = {
      active_border = { colors = { rgb(scheme.base0E), rgb(scheme.base0D) }, angle = 45 },
      inactive_border = rgb(scheme.base02),
    },

    resize_on_border = true,
  },

  decoration = {
    rounding = frame.window_radius,

    shadow = {
      enabled = true,
      range = 24,
      render_power = 3,
      color = rgba(scheme.base01, 0.63),
    },

    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = false,
    },
  },

  dwindle = {
    force_split = 2,
    preserve_split = true,
  },
})

-- Same curve as Tokens.motion.bezier.
hl.curve("standard", { type = "bezier", points = { { 0.2, 0.0 }, { 0.0, 1.0 } } })

hl.animation({ leaf = "global", enabled = true, speed = 1.5, bezier = "standard" })
hl.animation({
  leaf = "specialWorkspace",
  enabled = true,
  speed = 1.5,
  bezier = "standard",
  style = "slidefadevert",
})

-- ignore_alpha keeps the blur to the frame itself, not the transparent rest of the surface.
hl.layer_rule({ name = "shell-blur", match = { namespace = "quickshell-.*" }, blur = true })
hl.layer_rule({ name = "shell-ignore-alpha", match = { namespace = "quickshell-.*" }, ignore_alpha = 0.4 })
