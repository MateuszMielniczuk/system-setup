-- Smart gaps: a single tiled window (w[tv1]) or a fullscreen one (f[1]) gets no gaps,
-- border or rounding. toggle() flips it (Super+G); a reload turns it back on.
local M = {}

local rules = {
    hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 }),
    hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 }),
    hl.window_rule({
        name  = "smartgaps-single",
        match = { float = false, workspace = "w[tv1]" },
        border_size = 0,
        rounding    = 0,
    }),
    hl.window_rule({
        name  = "smartgaps-fullscreen",
        match = { float = false, workspace = "f[1]" },
        border_size = 0,
        rounding    = 0,
    }),
}

local enabled = true

function M.toggle()
    enabled = not enabled
    for _, rule in ipairs(rules) do
        rule:set_enabled(enabled)
    end
    hl.notification.create({ text = "Smart gaps " .. (enabled and "on" or "off"), timeout = 1500 })
end

return M
