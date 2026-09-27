hl.config({
  input = {
    kb_layout = "se",
    kb_options = "caps:super",

    numlock_by_default = true,
    repeat_delay = 300,
    float_switch_override_focus = 0,

    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.8,
    },
  },

  gestures = {
    workspace_swipe_distance = 500,
    workspace_swipe_forever = true,
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
