-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

local function window(match, effects)
  effects.match = match
  hl.window_rule(effects)
end

window({ class = ".*" }, { suppress_event = "maximize" })

-- A dash of opacity by default; apps below can opt out by removing the tag
window({ class = ".*" }, { tag = "+default-opacity" })

-- Fix some dragging issues with XWayland
window({ class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  { no_focus = true })

-- Browsers: tiled (works around an --app bug), only a subtle opacity change
window({ class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable)" },
  { tag = "+chromium-based-browser" })
window({ class = "([fF]irefox|zen|librewolf)" }, { tag = "+firefox-based-browser" })
window({ tag = "chromium-based-browser" }, { tag = "-default-opacity", tile = true, opacity = "1.0 0.97" })
window({ tag = "firefox-based-browser" }, { tag = "-default-opacity", opacity = "1.0 0.97" })

-- Picture-in-picture overlays
window({ title = "(Picture.?in.?[Pp]icture)" }, { tag = "+pip" })
window({ tag = "pip" }, {
  tag = "-default-opacity",
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

-- Floating windows: small tools and file dialogs
window({ class = "(Wiremix|bluetui|nmtui|com.gabm.satty|org.gnome.NautilusPreviewer|Archype|TUI.float)" },
  { tag = "+floating-window" })
window({ class = "xdg-desktop-portal-gtk" }, { tag = "+floating-window" })
-- Extension windows popped out of Brave, like Bitwarden (class is brave-<extension id>-<profile>).
-- No forced size: they pick their own and flicker when it's overridden.
-- Web apps installed from Brave get the same kind of class, so they float too.
window({ class = "brave-[a-p]{32}-.*" }, { float = true, center = true })
window({ tag = "floating-window" }, { float = true, center = true, size = { 800, 600 } })

-- No transparency on media windows
window({ class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" },
  { tag = "-default-opacity" })

-- Apply the default opacity after apps had a chance to opt out
window({ tag = "default-opacity" }, { opacity = "0.97 0.9" })

-- Vicinae: blurred background, no fade animation
hl.layer_rule({ match = { namespace = "vicinae" }, blur = true, ignore_alpha = 0, no_anim = true })

-- Remove the 1px border around screenshot region selection
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
