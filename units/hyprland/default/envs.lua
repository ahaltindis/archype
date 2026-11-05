-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
  -- Don't show update news on first launch
  ecosystem = {
    no_update_news = true,
  },
  -- Default on since 0.57; makes hyprlock crash when the screen wakes from DPMS
  -- (https://github.com/hyprwm/hyprlock/issues/1064)
  quirks = {
    skip_non_kms_dmabuf_formats = false,
  },
})
