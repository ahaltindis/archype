-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- Use the keyboard layout chosen during the Arch install
local function vconsole(key)
  local file = io.open("/etc/vconsole.conf", "r")
  if not file then
    return nil
  end
  local value
  for line in file:lines() do
    local k, v = line:match("^%s*([%w_]+)%s*=%s*\"?([^\"]*)\"?%s*$")
    if k == key then
      value = v
    end
  end
  file:close()
  return value
end

hl.config({
  input = {
    kb_layout = vconsole("XKBLAYOUT") or "us",
    kb_variant = vconsole("XKBVARIANT") or "",
    kb_options = "compose:caps",
    follow_mouse = 1,
    -- -1.0 to 1.0, 0 means no change
    sensitivity = 0,
    natural_scroll = true,
    touchpad = {
      natural_scroll = true,
    },
  },
})
