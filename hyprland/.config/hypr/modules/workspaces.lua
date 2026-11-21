-- 2x2 grid:  1 2
--            3 4
local M = { cols = 2, rows = 2 }

for i = 1, M.cols * M.rows do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

local steps = {
    left  = { -1, 0 },
    right = { 1, 0 },
    up    = { 0, -1 },
    down  = { 0, 1 },
}

local function target(direction)
    local ws = hl.get_active_workspace()
    local id = ws and ws.id or 1
    if id < 1 or id > M.cols * M.rows then
        return 1
    end
    local col = (id - 1) % M.cols + steps[direction][1]
    local row = (id - 1) // M.cols + steps[direction][2]
    if col < 0 or col >= M.cols or row < 0 or row >= M.rows then
        return nil
    end
    return row * M.cols + col + 1
end

local function set_slide(direction)
    local style = (direction == "up" or direction == "down") and "slidevert" or "slide"
    pcall(hl.animation, { leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = style })
end

function M.go(direction)
    return function()
        local t = target(direction)
        if t then
            set_slide(direction)
            hl.dispatch(hl.dsp.focus({ workspace = t }))
        end
    end
end

function M.take(direction)
    return function()
        local t = target(direction)
        if t then
            set_slide(direction)
            hl.dispatch(hl.dsp.window.move({ workspace = t, follow = true }))
        end
    end
end

return M
