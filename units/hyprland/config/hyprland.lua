-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Archype defaults. Don't edit them here; they're updated by the installer.
dofile(os.getenv("HOME") .. "/.config/archype/hyprland/archype.lua")

-- Your own setup. Loaded after the defaults, so anything here overrides them.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.envs")
require("hypr.autostart")
