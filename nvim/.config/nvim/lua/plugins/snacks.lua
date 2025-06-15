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

