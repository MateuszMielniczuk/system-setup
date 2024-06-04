return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Set header
        dashboard.section.header.val = {
            "                                                     ",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
            "                                                     ",
        }

        -- Set menu
        dashboard.section.buttons.val = {
            -- dashboard.button("e", " " .. " Toggle file explorer", ":Ex<CR>"),
            -- dashboard.button("n", " " .. " New File", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "󰱼 " .. " Search File", ":Telescope find_files<CR>"),
            dashboard.button("g", " " .. " Find Word", ":Telescope live_grep<CR>"),
            dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
            dashboard.button(
                "s",
                "󰁯 " .. " Restore Session For Current Directory",
                ":SessionRestore<CR>"
            ),
            dashboard.button("l", " " .. " Open package manager", ":Lazy<CR>"),
            dashboard.button("c", " " .. " Config", ":e ~/.config/nvim/ <CR>"),
            dashboard.button("q", " " .. " Quit NVIM", ":qa<CR>"),
        }

        -- Send config to alpha
        alpha.setup(dashboard.opts)

        -- Disable folding on alpha buffer
        vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
    end,
}
