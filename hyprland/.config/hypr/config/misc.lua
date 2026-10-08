hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    anr_missed_pings = 15,
    initial_workspace_tracking = 0,
    mouse_move_enables_dpms = true,
    -- If the shell dies while locked, the session stays locked; this lets the
    -- restarted shell take the lock over instead of leaving the red screen.
    allow_session_lock_restore = true,
  },

  cursor = {
    enable_hyprcursor = false,
    no_hardware_cursors = 0,
    inactive_timeout = 3,
    no_warps = true,
    warp_on_change_workspace = 2,
  },

  render = {
    direct_scanout = 1,
  },

  xwayland = {
    force_zero_scaling = true,
  },

  ecosystem = {
    no_donation_nag = true,
  },
})
