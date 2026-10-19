-- Yazi Lua config. Personal settings go in user.lua next to this file, which is loaded if it exists.
-- https://yazi-rs.github.io/docs/plugins/overview

local dir = os.getenv("YAZI_CONFIG_HOME")
	or (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/yazi"
local user = dir .. "/user.lua"

local f = io.open(user)
if f then
	f:close()
	local ok, err = pcall(dofile, user)
	if not ok then
		ya.notify({ title = "user.lua", content = tostring(err), timeout = 10, level = "error" })
	end
end
