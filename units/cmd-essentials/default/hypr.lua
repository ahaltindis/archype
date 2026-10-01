-- Added to Hyprland by the cmd-essentials unit (loaded by ~/.config/archype/hyprland/archype.lua)

hl.on("hyprland.start", function()
  -- Wait for the notification daemon to be up
  hl.exec_cmd("sleep 3 && archype-git-identity-reminder")
end)
