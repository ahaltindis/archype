-- Archype Hyprland defaults, loaded by ~/.config/hypr/hyprland.lua.
-- Don't edit these files; they are replaced on every install. Override in ~/.config/hypr/.

local home = os.getenv("HOME")
local archype = home .. "/.config/archype"

-- require() caches modules for the life of Hyprland; forget ours so `hyprctl reload` sees edits
for module in pairs(package.loaded) do
  if module:match("^archype%.") or module:match("^hypr%.") then
    package.loaded[module] = nil
  end
end

-- require("archype.hyprland.envs") -> ~/.config/archype/hyprland/envs.lua
-- require("hypr.monitors")         -> ~/.config/hypr/monitors.lua
if not package.path:find(home .. "/.config/?.lua", 1, true) then
  package.path = home .. "/.config/?.lua;" .. package.path
end

require("archype.hyprland.envs")
require("archype.hyprland.autostart")
require("archype.hyprland.bindings")
require("archype.hyprland.looknfeel")
require("archype.hyprland.input")
require("archype.hyprland.windows")

local function dofile_if_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    dofile(path)
  end
end

-- Current theme
dofile_if_exists(archype .. "/current/theme/hyprland.lua")

-- Additions from other units: ~/.config/archype/<unit>/hypr.lua
local unit_files = io.popen("ls -1 " .. archype .. "/*/hypr.lua 2>/dev/null")
if unit_files then
  for path in unit_files:lines() do
    dofile(path)
  end
  unit_files:close()
end
