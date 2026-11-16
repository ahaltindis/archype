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

-- Layouts added from the keyboard menu (archype-keyboard): "layout<TAB>variant" per line
local function added_layouts()
  local file = io.open(os.getenv("HOME") .. "/.local/state/archype/keyboard/layouts", "r")
  if not file then
    return nil
  end
  local layouts, variants = {}, {}
  for line in file:lines() do
    local layout, variant = line:match("^([^\t]+)\t?(.*)$")
    if layout then
      table.insert(layouts, layout)
      table.insert(variants, variant)
    end
  end
  file:close()
  if #layouts == 0 then
    return nil
  end
  return table.concat(layouts, ","), table.concat(variants, ",")
end

-- Added layouts win over the one from the Arch install
local layouts, variants = added_layouts()

hl.config({
  input = {
    kb_layout = layouts or vconsole("XKBLAYOUT") or "us",
    kb_variant = variants or vconsole("XKBVARIANT") or "",
    kb_options = "compose:caps",
    -- Click to focus; hovering doesn't change focus, but scrolling reaches the window under the cursor
    follow_mouse = 2,
    -- Same for moving between tiled and floating windows (default 1 switches focus)
    float_switch_override_focus = 0,
    -- -1.0 to 1.0, 0 means no change
    sensitivity = 0,
    natural_scroll = true,
    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace", scale = 5.0 })
