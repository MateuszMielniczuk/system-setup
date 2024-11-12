-- INFO: Plugin that displays a popup with possible key bindings
--

return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    config = function()
        local status_ok, which_key = pcall(require, "which-key")
        if not status_ok then
            return
        end

        local setup = {
            plugins = {
                marks = true, -- shows a list of your marks on ' and `
                registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
                spelling = {
                    enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                    suggestions = 20, -- how many suggestions should be shown in the list?
                },
                -- the presets plugin, adds help for a bunch of default keybindings in Neovim
                -- No actual key bindings are created
                presets = {
                    operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
                    motions = true, -- adds help for motions
                    text_objects = true, -- help for text objects triggered after entering an operator
                    windows = true, -- default bindings on <c-w>
                    nav = true, -- misc bindings to work with windows
                    z = true, -- bindings for folds, spelling and others prefixed with z
                    g = true, -- bindings for prefixed with g
                },
            },
            -- add operators that will trigger motion and text object completion
            -- to enable all native operators, set the preset / operators plugin above
            -- operators = { gc = "Comments" },
            icons = {
                breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                separator = "➜", -- symbol used between a key and it's label
                group = "+", -- symbol prepended to a group
            },
            -- popup_mappings = {
            --     scroll_down = "<c-j>", -- binding to scroll down inside the popup
            --     scroll_up = "<c-k>", -- binding to scroll up inside the popup
            -- },
            ---@type wk.Win.opts
            win = {
                no_overlap = true, --don't allow the popup to overlap with the cursor
                border = "none", -- none, single, double, shadow
                -- position = "bottom", -- bottom, top
                -- margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
                padding = { 2, 2 }, -- extra window padding [top, right, bottom, left]
                title = true,
                title_pos = "center",
                bo = {},
                wo = {
                    winblend = 2, -- value between 0 and 100,100 is fully transparent
                },
                zindex = 1000, -- positive value to position WhichKey above other floating windows.
            },
            layout = {
                height = { min = 4, max = 25 }, -- min and max height of the columns
                width = { min = 20, max = 50 }, -- min and max width of the columns
                spacing = 3, -- spacing between columns
                align = "left", -- align columns left, center or right
            },
            -- ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label

            -- hide mapping boilerplate
            -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
            show_help = true, -- show help message on the command line when the popup is visible
            show_keys = true, -- show the currently pressed key and its label as a message in the command line
            -- Disabled by default for Telescope
            disable = {
                buftypes = {},
                filetypes = { "TelescopePrompt" },
            },
            -- Which-key automatically sets up triggers for your mappings.
            -- But you can disable this and setup the triggers manually.
            -- Check the docs for more info.
            ---@type wk.Spec
            triggers = {
                { "<auto>", mode = "nxso" },
            },
            -- triggers = "auto", -- automatically setup triggers
            -- triggers_nowait = {
            --     -- marks
            --     "`",
            --     "'",
            --     "g`",
            --     "g'",
            --     -- registers
            --     '"',
            --     "<c-r>",
            --     -- spelling
            --     "z=",
            -- },
            -- triggers_blacklist = {
            --     -- list of mode / prefixes that should never be hooked by WhichKey
            --     -- this is mostly relevant for key maps that start with a native binding
            --     -- most people should not need to change this
            --     i = { "j", "k" },
            --     v = { "j", "k" },
            -- },
        }

        local opts = {
            mode = "n", -- NORMAL mode
            prefix = "<leader>",
            buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
            silent = true, -- use `silent` when creating keymaps
            noremap = true, -- use `noremap` when creating keymaps
            nowait = true, -- use `nowait` when creating keymaps
        }

        local mappings = {
            { "<leader>a", group = "AI" },
            {
                "<leader>b",
                group = "buffers",
                expand = function()
                    return require("which-key.extras").expand.buf()
                end,
            },
            { "<leader>c", group = "Code Action" },
            { "<leader>d", group = "Diagnostics" },
            { "<leader>g", group = "Go to" },
            { "<leader>h", group = "Hoover" },
            { "<leader>l", group = "LSP" },
            { "<leader>s", group = "Search" },
            { "<leader>t", group = "Tab nav" },
            -- bp - move to previous buffer,
            -- bd # - kill buffer from which just moved away
            {
                mode = { "n", "v" }, -- for normal and visual mode
                { "<leader>k", "<cmd>bp|bd #<CR>", desc = "Kill buffer", icon = "", mode = "n" },
                { "<leader>p", "<cmd>Lazy<CR>", desc = "Plugin manager", icon = "", mode = "n" },
                { "<leader>q", "<cmd>q<CR>", desc = "Quit Neovim", mode = "n" },
                { "<leader>w", "<cmd>w!<CR>", desc = "Write - save file", mode = "n" },
                {
                    "<leader>e",
                    "<cmd>Ex<CR>",
                    desc = "File Explorer - Open full screen",
                    mode = "n",
                },
                -- ["E"] = { "<cmd>Lexplore<CR>", "File Explorer - toggle left" },
                { "<leader>m", "<cmd>Mason<CR>", desc = "Mason open", icon = " ", mode = "n" }, -- LSP manager
            },
        }

        which_key.setup(setup)
        -- which_key.register(mappings, opts)
        which_key.add(mappings, opts)
    end,
}
