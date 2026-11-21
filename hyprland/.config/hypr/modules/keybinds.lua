local grid = require("modules.workspaces")

local mod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "fuzzel"

local function bind(keys, action, opts)
    hl.bind(mod .. " + " .. keys, action, opts)
end

-- Apps
bind("Return", hl.dsp.exec_cmd(terminal))
bind("Space",  hl.dsp.exec_cmd(menu))
bind("E",      hl.dsp.exec_cmd(fileManager))

-- Windows
bind("Q",             hl.dsp.window.close())
bind("F",             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind("M",             hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
bind("SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
bind("S",             hl.dsp.layout("togglesplit"))
bind("P",             hl.dsp.window.pseudo())

-- Session
bind("SHIFT + E", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Focus / move / resize: vim keys and arrows
local dirs = {
    { "H", "left" }, { "J", "down" }, { "K", "up" }, { "L", "right" },
    { "left", "left" }, { "down", "down" }, { "up", "up" }, { "right", "right" },
}
local resize = { left = { -40, 0 }, right = { 40, 0 }, up = { 0, -40 }, down = { 0, 40 } }

for _, d in ipairs(dirs) do
    local key, dir = d[1], d[2]
    bind(key,                 hl.dsp.focus({ direction = dir }))
    bind("SHIFT + " .. key,   hl.dsp.window.move({ direction = dir }))
    bind("ALT + " .. key,     hl.dsp.window.resize({ x = resize[dir][1], y = resize[dir][2], relative = true }), { repeating = true })
    -- Workspace grid
    bind("CTRL + " .. key,         grid.go(dir))
    bind("CTRL + SHIFT + " .. key, grid.take(dir))
end

-- Mouse
bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media and brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
