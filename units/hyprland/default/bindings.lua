-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- Options: locked = works on the lock screen, repeating = repeats while held, mouse = drag binding

local function bind(keys, description, dispatcher, options)
  local opts = options or {}
  opts.description = description
  if type(dispatcher) == "string" then
    dispatcher = hl.dsp.exec_cmd(dispatcher)
  end
  hl.bind(keys, dispatcher, opts)
end

-- Apps
bind("SUPER + SPACE", "Launcher", "uwsm app -- vicinae toggle")
bind("SUPER + RETURN", "Terminal", "uwsm app -- alacritty")
bind("SUPER + B", "Browser", "uwsm app -- brave")
bind("SUPER + E", "File manager", "uwsm app -- alacritty -e yazi")

-- System
bind("SUPER + CTRL + L", "Lock screen", "archype-lock-screen")
bind("SUPER + CTRL + SPACE", "Next background in theme", "archype-theme-bg-next")
bind("SUPER + CTRL + B", "Toggle top bar", "pkill -SIGUSR1 waybar")
bind("SUPER + CTRL + I", "Toggle locking on idle", "archype-toggle-idle")
bind("SUPER + CTRL + N", "Toggle nightlight", "archype-toggle-nightlight")

-- Notifications
bind("SUPER + COMMA", "Dismiss last notification", "makoctl dismiss")
bind("SUPER + SHIFT + COMMA", "Dismiss all notifications", "makoctl dismiss --all")
bind("SUPER + CTRL + COMMA", "Toggle silencing notifications",
  "makoctl mode -t do-not-disturb && makoctl mode | grep -q 'do-not-disturb' && notify-send 'Silenced notifications' || notify-send 'Enabled notifications'")

-- Screenshots and color picker
bind("ALT + SHIFT + 1", "Color picker", "pkill hyprpicker || hyprpicker -a")
bind("ALT + SHIFT + 3", "Screenshot of region", "archype-cmd-screenshot")
bind("ALT + SHIFT + 4", "Screenshot of window", "archype-cmd-screenshot window")
bind("ALT + SHIFT + 5", "Screenshot of display", "archype-cmd-screenshot output")

-- Windows
bind("SUPER + Q", "Close active window", hl.dsp.window.close())
bind("SUPER + T", "Toggle split", hl.dsp.layout("togglesplit"))
bind("SUPER + P", "Pseudo window", hl.dsp.window.pseudo())
bind("SUPER + V", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

for key, dir in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
  local name = ({ l = "left", d = "down", u = "up", r = "right" })[dir]
  bind("SUPER + " .. key, "Move focus " .. name, hl.dsp.focus({ direction = dir }))
  bind("SUPER + SHIFT + " .. key, "Swap window " .. name, hl.dsp.window.swap({ direction = dir }))
end

bind("ALT + TAB", "Cycle to next window", hl.dsp.window.cycle_next())
bind("ALT + SHIFT + TAB", "Cycle to previous window", hl.dsp.window.cycle_next({ next = false }))
bind("ALT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
bind("ALT + SHIFT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())

-- Resize with SUPER + minus/equal (code:20/21)
bind("SUPER + code:20", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
bind("SUPER + code:21", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
bind("SUPER + SHIFT + code:20", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
bind("SUPER + SHIFT + code:21", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Move and resize with the mouse
bind("SUPER + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
bind("SUPER + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- Workspaces: SUPER + [1-0] to switch, SUPER + SHIFT + [1-0] to move the window there
for workspace = 1, 10 do
  local key = "code:" .. (workspace + 9)
  bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace) }))
end

bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
bind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
bind("SUPER + mouse_up", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
bind("SUPER + mouse_down", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))

-- Volume, brightness and media keys, with the OSD on the focused monitor
local osd = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\""
local media = { locked = true }
local media_repeat = { locked = true, repeating = true }

bind("XF86AudioRaiseVolume", "Volume up", osd .. " --output-volume raise", media_repeat)
bind("XF86AudioLowerVolume", "Volume down", osd .. " --output-volume lower", media_repeat)
bind("XF86AudioMute", "Mute", osd .. " --output-volume mute-toggle", media)
bind("XF86AudioMicMute", "Mute microphone", osd .. " --input-volume mute-toggle", media)
bind("XF86MonBrightnessUp", "Brightness up", osd .. " --brightness raise", media_repeat)
bind("XF86MonBrightnessDown", "Brightness down", osd .. " --brightness lower", media_repeat)

bind("ALT + XF86AudioRaiseVolume", "Volume up precise", osd .. " --output-volume +1", media_repeat)
bind("ALT + XF86AudioLowerVolume", "Volume down precise", osd .. " --output-volume -1", media_repeat)
bind("ALT + XF86MonBrightnessUp", "Brightness up precise", osd .. " --brightness +1", media_repeat)
bind("ALT + XF86MonBrightnessDown", "Brightness down precise", osd .. " --brightness -1", media_repeat)

bind("XF86AudioNext", "Next track", osd .. " --playerctl next", media)
bind("XF86AudioPause", "Pause", osd .. " --playerctl play-pause", media)
bind("XF86AudioPlay", "Play", osd .. " --playerctl play-pause", media)
bind("XF86AudioPrev", "Previous track", osd .. " --playerctl previous", media)
bind("SUPER + XF86AudioMute", "Switch audio output", "archype-manage-audio-switch", media)
