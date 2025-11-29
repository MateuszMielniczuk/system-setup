return {
    -- change welcome screen greeter
    "snacks.nvim",
    opts = {
        -- Dashboard =================================================
        dashboard = {
            preset = {
                pick = function(cmd, opts)
                    return LazyVim.pick(cmd, opts)()
                end,
                header = [[
        ██╗   ██╗
         ██████╗██████╗  █████╗ ██║   ██║████████╗███████╗ ██████╗ 
        ██╔════╝██╔══██╗██╔══██╗██║   ██║╚══██╔══╝██╔════╝ ╚════██╗
        ██║     ██████╔╝███████║██║   ██║   ██║   █████╗        ██║
        ██║     ██╔══██╗██╔══██║╚██╗ ██╔╝   ██║   ██╔══╝        ██║
        ║██████ ██║  ██║██║  ██║ ╚████╔╝    ██║   ███████╗ ██████╔╝
         ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝     ╚═╝   ╚══════╝ ╚═════╝ 
        by MMi
 ]],
                -- stylua: ignore
                ---@type snacks.dashboard.Item[]
                keys = {
                    { icon = "", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                    { icon = "", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = "", key = "p", desc = "Projects", action = ":lua Snacks.dashboard.pick('projects')" },
                    { icon = "", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                    { icon = "", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                    { icon = "", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                    { icon = "", key = "s", desc = "Restore Session", section = "session" },
                    { icon = "", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
                    { icon = "󰛨", key = "m", desc = "Mason", action = ":Mason" },
                    { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                    { icon = "", key = "q", desc = "Quit", action = ":qa" },
                },
            },
        },

        -- Indentation lines =========================================
        indent = {
            indent = {
                char = "┊",
            },
            scope = {
                char = "┊",
            },
            animate = {
                enabled = false,
            },
        },
        scroll = {
            animate = {
                duration = { step = 7, total = 100 },
            },
        },
    },
}

