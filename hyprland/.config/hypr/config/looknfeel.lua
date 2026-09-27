hl.config({
  general = {
    layout = "dwindle",

    gaps_in = 4,
    gaps_out = { top = 3, right = 8, bottom = 8, left = 8 },

    col = {
      active_border = "rgb(cba6f7)", -- mauve
      inactive_border = "rgb(181825)", -- mantle
    },

    resize_on_border = true,
  },

  decoration = {
    rounding = 5,

    blur = {
      size = 5,
      passes = 3,
      ignore_opacity = false,
    },
  },

  dwindle = {
    force_split = 2,
    preserve_split = true,
  },
})

hl.curve("snappy", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 1.5, bezier = "snappy" })
hl.animation({
  leaf = "specialWorkspace",
  enabled = true,
  speed = 1.5,
  bezier = "snappy",
  style = "slidefadevert",
})
