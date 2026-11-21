-- Docked layout: ultrawide on top, laptop below it, centered
--   G34w 3440x1440 @1.0  -> 0x0
--   eDP-1 1920x1200 @1.0 -> 1280x800 logical, x = (3440-1280)/2
local laptop = "eDP-1"

local function lid_closed()
    local f = io.open("/proc/acpi/button/lid/LID/state")
    if not f then
        return false
    end
    local state = f:read("*a")
    f:close()
    return state:find("closed") ~= nil
end

local function has_external()
    for _, m in ipairs(hl.get_monitors() or {}) do
        if m.name ~= laptop then
            return true
        end
    end
    return false
end

hl.monitor({
    output   = "desc:Lenovo Group Limited LEN G34w-10 UGW05H2N",
    mode     = "3440x1440@60",
    position = "0x0",
    scale    = 1,
})

if lid_closed() and has_external() then
    hl.monitor({ output = laptop, disabled = true })
else
    hl.monitor({ output = laptop, mode = "preferred", position = "1080x1440", scale = 1.0 })
end

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Put every screen on the current desktop (see workspaces.lua)
local function fix_workspaces()
    require("modules.workspaces").sync()
end

local function later(fn, ms)
    hl.timer(fn, { timeout = ms or 300, type = "oneshot" })
end

local function reload()
    hl.dispatch(hl.dsp.reload_config())
end

-- Lid: reload so the rules above re-evaluate (logind suspends when undocked)
hl.bind("switch:on:Lid Switch",  function() later(reload) end, { locked = true })
hl.bind("switch:off:Lid Switch", function() later(reload) end, { locked = true })

hl.on("monitor.added", function(m)
    later(fix_workspaces)
    if lid_closed() and m and m.name ~= laptop then
        later(reload)
    end
end)

hl.on("monitor.removed", function(m)
    later(fix_workspaces)
    if lid_closed() and m and m.name ~= laptop then
        later(reload)
    end
end)

-- Monitor check: hl.timer segfaults `Hyprland --verify-config` (0.57.2), which has no monitors
hl.on("config.reloaded", function()
    if #(hl.get_monitors() or {}) > 0 then
        later(fix_workspaces)
    end
end)
