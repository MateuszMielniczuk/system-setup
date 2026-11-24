-- Touchpad gestures
--   3 fingers: switch desktop in the 2x2 grid (natural: content follows the fingers)
--   4 fingers up/down: move window to the screen above/below
--   4 fingers pinch: in = fullscreen, out = back to normal
local grid = require("modules.workspaces")

local natural = { left = "right", right = "left", up = "down", down = "up" }
for swipe, desktop in pairs(natural) do
    hl.gesture({ fingers = 3, direction = swipe, action = grid.go(desktop) })
end

local function to_screen(dir)
    return function()
        local current = hl.get_active_monitor()
        if not current then
            return
        end
        for _, m in ipairs(hl.get_monitors() or {}) do
            local above = m.y + m.height / m.scale <= current.y
            local below = m.y >= current.y + current.height / current.scale
            if m.name ~= current.name and ((dir == "up" and above) or (dir == "down" and below)) then
                hl.dispatch(hl.dsp.window.move({ workspace = m.active_workspace.id, follow = true }))
                return
            end
        end
    end
end

hl.gesture({ fingers = 4, direction = "up", action = to_screen("up") })
hl.gesture({ fingers = 4, direction = "down", action = to_screen("down") })

hl.gesture({ fingers = 4, direction = "pinchin", action = function()
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set" }))
end })
hl.gesture({ fingers = 4, direction = "pinchout", action = function()
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "unset" }))
end })
