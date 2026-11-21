-- Descriptions feed the cheat sheet (hub.sh keys) as "[Group] text"
-- or "[Group|key label] text" to show one line for several keys.
local grid = require("modules.workspaces")

local mod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "fuzzel"
local scripts = "~/.config/hypr/scripts/"

local group = ""
local function section(name)
    group = name
end

local function key(keys, action, desc, opts)
    opts = opts or {}
    if desc then
        opts.description = desc:sub(1, 1) == "[" and desc or ("[" .. group .. "] " .. desc)
    end
    hl.bind(keys, action, opts)
end

local function bind(keys, action, desc, opts)
    key(mod .. " + " .. keys, action, desc, opts)
end

section("Apps")
bind("Return", hl.dsp.exec_cmd(terminal),    "Terminal")
bind("Space",  hl.dsp.exec_cmd(menu),        "App launcher")
bind("E",      hl.dsp.exec_cmd(fileManager), "File manager")
bind("Y",      hl.dsp.exec_cmd(terminal .. " --class yazi -e yazi"), "File manager (yazi)")
bind("A",      hl.dsp.exec_cmd(scripts .. "hub.sh"),      "Settings hub")
bind("slash",  hl.dsp.exec_cmd(scripts .. "hub.sh keys"), "Keybindings cheat sheet")
bind("V",      hl.dsp.exec_cmd(scripts .. "clipboard.sh"), "Clipboard history")

-- Dropdown terminal
bind("grave", function()
    if #hl.get_windows({ class = "dropterm" }) == 0 then
        hl.dispatch(hl.dsp.exec_cmd("kitty --class dropterm"))
    else
        hl.dispatch(hl.dsp.workspace.toggle_special("term"))
    end
end, "Dropdown terminal")

section("Windows")
bind("Q",             hl.dsp.window.close(),                                               "Close window")
bind("F",             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), "Fullscreen")
bind("M",             hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),  "Maximize")
bind("SHIFT + Space", hl.dsp.window.float({ action = "toggle" }),                          "Toggle floating")
bind("S",             hl.dsp.layout("togglesplit"),                                        "Toggle split direction")
bind("P",             hl.dsp.window.pseudo(),                                              "Pseudo-tile")
bind("G",             require("modules.smartgaps").toggle,                                 "Toggle smart gaps")
bind("C",             hl.dsp.window.center(),                                              "Center floating window")

-- Pin: float at 60% of the screen, centered, shown on every desktop of this screen;
-- again to unpin and tile. (Floating at tiled size could cover the whole screen
-- and spill onto the other monitor.)
local function toggle_pin()
    local w = hl.get_active_window()
    if not w then
        return
    end
    if w.pinned then
        hl.dispatch(hl.dsp.window.pin({ action = "unset" }))
        hl.dispatch(hl.dsp.window.float({ action = "unset" }))
    else
        local m = w.monitor or hl.get_active_monitor()
        if not w.floating then
            hl.dispatch(hl.dsp.window.float({ action = "set" }))
        end
        if m then
            hl.dispatch(hl.dsp.window.resize({
                x = math.floor(m.width / m.scale * 0.6),
                y = math.floor(m.height / m.scale * 0.6),
            }))
        end
        hl.dispatch(hl.dsp.window.center())
        hl.dispatch(hl.dsp.window.pin({ action = "set" }))
    end
end
bind("SHIFT + P", toggle_pin, "Pin window (all desktops)")

-- Focus / move / resize and desktop grid: vim keys and arrows, one cheat sheet line each
local dirs = {
    { "H", "left" }, { "J", "down" }, { "K", "up" }, { "L", "right" },
    { "left", "left" }, { "down", "down" }, { "up", "up" }, { "right", "right" },
}
local resize = { left = { -40, 0 }, right = { 40, 0 }, up = { 0, -40 }, down = { 0, 40 } }

for _, d in ipairs(dirs) do
    local k, dir = d[1], d[2]
    local function desc(grp, mods, text)
        return k == "H" and ("[" .. grp .. "|Super + " .. mods .. "H/J/K/L or arrows] " .. text) or nil
    end
    bind(k,                      hl.dsp.focus({ direction = dir }),       desc("Windows", "", "Focus window"))
    bind("SHIFT + " .. k,        hl.dsp.window.move({ direction = dir }), desc("Windows", "Shift + ", "Move window"))
    bind("ALT + " .. k,          hl.dsp.window.resize({ x = resize[dir][1], y = resize[dir][2], relative = true }),
        desc("Windows", "Alt + ", "Resize window"), { repeating = true })
    bind("CTRL + " .. k,         grid.go(dir),   desc("Desktops", "Ctrl + ", "Switch desktop"))
    bind("CTRL + SHIFT + " .. k, grid.take(dir), desc("Desktops", "Ctrl + Shift + ", "Take window to desktop"))
end

section("Mouse")
bind("mouse:272", hl.dsp.window.drag(),   "Drag window",   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

section("Zoom")
-- Screen zoom around the cursor (view only; reset on reload)
local zoom_steps = { 1, 1.25, 1.5, 2, 3 }

local function set_zoom(value)
    hl.config({ cursor = { zoom_factor = math.max(1, math.min(value, 4)) } })
end

local function zoom_step(dir)
    return function()
        local current = tonumber((hl.get_config("cursor.zoom_factor"))) or 1
        local target = dir > 0 and zoom_steps[#zoom_steps] or 1
        for i = 1, #zoom_steps do
            local s = dir > 0 and zoom_steps[i] or zoom_steps[#zoom_steps + 1 - i]
            if (dir > 0 and s > current + 0.01) or (dir < 0 and s < current - 0.01) then
                target = s
                break
            end
        end
        set_zoom(target)
    end
end

local function zoom_scale(factor)
    return function()
        set_zoom((tonumber((hl.get_config("cursor.zoom_factor"))) or 1) * factor)
    end
end

bind("equal", zoom_step(1),  "Zoom in")
bind("minus", zoom_step(-1), "Zoom out")
bind("0",     function() set_zoom(1) end, "Reset zoom")
bind("ALT + mouse_up",   zoom_scale(1.1),     "Zoom in (wheel)")
bind("ALT + mouse_down", zoom_scale(1 / 1.1), "Zoom out (wheel)")

section("Capture")
key("Print",         hl.dsp.exec_cmd(scripts .. "screenshot.sh region"),      "Screenshot region")
key("SHIFT + Print", hl.dsp.exec_cmd(scripts .. "screenshot.sh screen"),      "Screenshot screen")
key("CTRL + Print",  hl.dsp.exec_cmd(scripts .. "screenshot.sh window"),      "Screenshot window")
bind("Print",        hl.dsp.exec_cmd(scripts .. "screenshot.sh region edit"), "Screenshot region and annotate")
bind("R",            hl.dsp.exec_cmd(scripts .. "record.sh region"),          "Record region (again to stop)")
bind("SHIFT + R",    hl.dsp.exec_cmd(scripts .. "record.sh screen"),          "Record screen (again to stop)")
bind("O",            hl.dsp.exec_cmd(scripts .. "ocr.sh text"),               "Copy text from region (OCR)")
bind("SHIFT + O",    hl.dsp.exec_cmd(scripts .. "ocr.sh qr"),                 "Copy QR code from region")

section("Theme")
bind("T",         hl.dsp.exec_cmd(scripts .. "theme.sh"),           "Theme picker")
bind("W",         hl.dsp.exec_cmd(scripts .. "hub.sh wallpaper"),   "Wallpaper picker")
bind("SHIFT + W", hl.dsp.exec_cmd(scripts .. "theme.sh wallpaper"), "Random wallpaper")
bind("CTRL + N",  hl.dsp.exec_cmd(scripts .. "nightlight.sh"),      "Night light")

section("Notifications")
bind("N",         hl.dsp.exec_cmd("makoctl dismiss"), "Dismiss notification")
bind("SHIFT + N", hl.dsp.exec_cmd("makoctl restore"), "Restore last notification")

section("Session")
bind("Escape",        hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), "Lock screen")
key("CTRL + ALT + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), "Lock screen")
bind("SHIFT + E",     hl.dsp.exec_cmd(scripts .. "powermenu.sh"),    "Power menu")
bind("SHIFT + B",     hl.dsp.exec_cmd("pkill waybar; waybar"),       "Restart bar")

-- Passthrough: all shortcuts off so keys reach a VM / remote desktop; same key exits.
-- Media keys and the lid switch stay active (submap_universal).
local function passthrough(on)
    return function()
        hl.dispatch(hl.dsp.submap(on and "passthrough" or "reset"))
        hl.exec_cmd(on and "notify-send -t 3000 'Passthrough on' 'All shortcuts off. Super+Alt+F1 to exit.'"
            or "notify-send -t 1500 'Passthrough off'")
    end
end
bind("ALT + F1", passthrough(true), "Passthrough mode (VMs, remote desktop)")
hl.define_submap("passthrough", function()
    hl.bind(mod .. " + ALT + F1", passthrough(false))
end)

section("Media")
key("CTRL + XF86AudioRaiseVolume", hl.dsp.exec_cmd(scripts .. "player-volume.sh +"), "Player volume up", { locked = true, repeating = true, submap_universal = true })
key("CTRL + XF86AudioLowerVolume", hl.dsp.exec_cmd(scripts .. "player-volume.sh -"), "Player volume down", { locked = true, repeating = true, submap_universal = true })

-- Media and brightness (osd.sh shows a popup with the new level)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(scripts .. "osd.sh volume up"),       { locked = true, repeating = true, submap_universal = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(scripts .. "osd.sh volume down"),     { locked = true, repeating = true, submap_universal = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(scripts .. "osd.sh volume mute"),     { locked = true, submap_universal = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(scripts .. "osd.sh mic mute"),        { locked = true, submap_universal = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scripts .. "osd.sh brightness up"),   { locked = true, repeating = true, submap_universal = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scripts .. "osd.sh brightness down"), { locked = true, repeating = true, submap_universal = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, submap_universal = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, submap_universal = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, submap_universal = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, submap_universal = true })
