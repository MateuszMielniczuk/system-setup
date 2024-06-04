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
            -- dashboard.button("n", " " .. " New File", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "󰱼 " .. " Search File", ":Telescope find_files<CR>"),
            dashboard.button("g", " " .. " Find Word", ":Telescope live_grep<CR>"),
            dashboard.button("e", " " .. " Open file explorer", ":Ex<CR>"),
            dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
            dashboard.button(
                "s",
                "󰁯 " .. " Restore Session",
                "<cmd>lua require('persistence').load()<cr>"
            ),
            dashboard.button("l", " " .. " Open package manager", ":Lazy<CR>"),
            dashboard.button("c", " " .. " Config", ":e ~/.config/nvim/ <CR>"),
            dashboard.button("q", " " .. " Quit NVIM", ":qa<CR>"),
        }

        local function footer()
            return [[Life is hard, vim is the only easy thing in it.]]
        end

        dashboard.section.footer.val = footer()
        dashboard.section.footer.opts.hl = "Type"
        dashboard.section.header.opts.hl = "Include"
        dashboard.section.buttons.opts.hl = "Keyword"

        -- Send config to alpha
        alpha.setup(dashboard.opts)

        -- Disable folding on alpha buffer
        vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
    end,
}
