local function launch(command)
  hl.exec_cmd("uwsm app -- " .. command)
end

hl.on("hyprland.start", function()
  launch("hypridle")
  launch("mako")
  launch("waybar")
  launch("vicinae server")
  launch("swaybg -i " .. os.getenv("HOME") .. "/.config/archype/current/background -m fill")
  launch("swayosd-server")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("wl-clip-persist --clipboard regular --all-mime-type-regex '^(?!x-kde-passwordManagerHint).+'")
end)
