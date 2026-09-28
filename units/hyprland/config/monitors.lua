-- https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions: hyprctl monitors all
-- Relaunch Hyprland after changing GDK_SCALE.

-- Straight 1x setup for low-resolution displays like 1080p or 1440p
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K
-- hl.env("GDK_SCALE", "2")
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })

-- A specific monitor
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })
