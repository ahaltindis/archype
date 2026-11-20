-- Added to Hyprland by the remote-client unit (loaded by ~/.config/archype/hyprland/archype.lua)

-- Keyboard to the remote desktop: in the "remote" submap no keybinding but the one below is caught
-- here, so Super and everything else reach the focused window (archype-remote's viewer).
hl.define_submap("remote", function()
  hl.bind("SUPER + CTRL + R", function()
    hl.dispatch(hl.dsp.submap("reset"))
    hl.exec_cmd("notify-send --app-name='Remote desktop' 'Keyboard back to this computer'")
  end, { description = "Keyboard back to this computer" })
end)

hl.bind("SUPER + CTRL + R", function()
  hl.dispatch(hl.dsp.submap("remote"))
  hl.exec_cmd("notify-send --app-name='Remote desktop' 'Keyboard to the remote desktop' 'Super + Ctrl + R gives it back'")
end, { description = "Keyboard to the remote desktop" })
