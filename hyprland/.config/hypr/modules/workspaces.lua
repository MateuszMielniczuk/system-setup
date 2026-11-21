-- KDE-style desktops: a desktop spans all screens and they switch together.
--   desktop d = workspace d on the external screen, 10+d on the laptop
--   grid:  1 2
--          3 4
local M = { cols = 2, rows = 2, laptop = "eDP-1" }
local count = M.cols * M.rows

for d = 1, count do
    hl.workspace_rule({ workspace = tostring(10 + d), monitor = M.laptop })
end

local function offset(monitor)
    return (monitor and monitor.name == M.laptop) and 10 or 0
end

function M.current()
    local ws = hl.get_active_workspace()
    local d = (ws and ws.id or 1) % 10
    if d < 1 or d > count then
        return 1
    end
    return d
end

local steps = {
    left  = { -1, 0 },
    right = { 1, 0 },
    up    = { 0, -1 },
    down  = { 0, 1 },
}

local function neighbour(direction)
    local d = M.current()
    local col = (d - 1) % M.cols + steps[direction][1]
    local row = (d - 1) // M.cols + steps[direction][2]
    if col < 0 or col >= M.cols or row < 0 or row >= M.rows then
        return nil
    end
    return row * M.cols + col + 1
end

local function set_slide(direction)
    local style = (direction == "up" or direction == "down") and "slidevert" or "slide"
    pcall(hl.animation, { leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = style })
end

function M.switch(d)
    local focused = hl.get_active_monitor()
    for _, m in ipairs(hl.get_monitors() or {}) do
        if not (focused and m.name == focused.name) then
            m:set_workspace(offset(m) + d)
        end
    end
    if focused then
        hl.dispatch(hl.dsp.focus({ workspace = offset(focused) + d }))
    end
end

-- When a screen goes away (lid closed, undocked), move its windows to the
-- same desktop on the remaining screen
local function collect_orphans()
    local laptop, external = false, false
    for _, m in ipairs(hl.get_monitors() or {}) do
        if m.name == M.laptop then
            laptop = true
        else
            external = true
        end
    end
    if laptop == external then
        return
    end
    local from = laptop and 0 or 10
    local to = laptop and 10 or 0
    for _, w in ipairs(hl.get_windows() or {}) do
        local id = w.workspace and w.workspace.id
        if id and id > from and id <= from + count then
            hl.dispatch(hl.dsp.window.move({ window = "address:" .. w.address, workspace = id - from + to, follow = false }))
        end
    end
end

function M.sync()
    collect_orphans()
    M.switch(M.current())
end

function M.go(direction)
    return function()
        local d = neighbour(direction)
        if d then
            set_slide(direction)
            M.switch(d)
        end
    end
end

function M.take(direction)
    return function()
        local d = neighbour(direction)
        if d then
            set_slide(direction)
            hl.dispatch(hl.dsp.window.move({ workspace = offset(hl.get_active_monitor()) + d, follow = false }))
            M.switch(d)
        end
    end
end

return M
