-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    -- Multiple keyboard layouts, switched with Left Alt + Right Alt
    -- kb_layout = "us,dk",
    -- kb_options = "compose:caps,grp:alts_toggle",

    -- Keyboard repeat speed
    repeat_rate = 40,
    repeat_delay = 600,

    -- Mouse/trackpad sensitivity (default: 0)
    -- sensitivity = 0.35,

    touchpad = {
      -- Two-finger click for right-click instead of the lower-right corner
      -- clickfinger_behavior = true,

      -- Scroll speed
      scroll_factor = 0.4,
    },
  },
})

-- Scroll faster in the terminal
hl.window_rule({ match = { class = "foot" }, scroll_touchpad = 1.5 })
