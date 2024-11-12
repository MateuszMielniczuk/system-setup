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
            ---@type false | "classic" | "modern" | "helix"
            preset = "classic",
            -- Delay before showing the popup. Can be a number or a function that returns a number.
            ---@type number | fun(ctx: { keys: string, mode: string, plugin?: string }):number
            delay = function(ctx)
                return ctx.plugin and 0 or 200
            end,
            -- show a warning when issues were detected with your mappings
            notify = true,
            -- Which-key automatically sets up triggers for your mappings.
            -- But you can disable this and setup the triggers manually.
            -- Check the docs for more info.
            ---@type wk.Spec
            triggers = {
                { "<auto>", mode = "nxso" },
            },
            -- Start hidden and wait for a key to be pressed before showing the popup
            -- Only used by enabled xo mapping modes.
            ---@param ctx { mode: string, operator: string }
            defer = function(ctx)
                return ctx.mode == "V" or ctx.mode == "<C-V>"
            end,
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
            ---@type wk.Win.opts
            win = {
                no_overlap = true, --don't allow the popup to overlap with the cursor
                -- width = 1,
                -- height = { min = 4, max = 25 },
                -- col = 0,
                -- row = math.huge,
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
                width = { min = 20, max = 50 }, -- min and max width of the columns
                spacing = 3, -- spacing between columns
            },
            keys = {
                scroll_down = "<c-j>", -- binding to scroll down inside the popup
                scroll_up = "<c-k>", -- binding to scroll up inside the popup
            },
            ---@type (string|wk.Sorter)[]
            --- Mappings are sorted using configured sorters and natural sort of the keys
            --- Available sorters:
            --- * local: buffer-local mappings first
            --- * order: order of the items (Used by plugins like marks / registers)
            --- * group: groups last
            --- * alphanum: alpha-numerical first
            --- * mod: special modifier keys last
            --- * manual: the order the mappings were added
            --- * case: lower-case first
            sort = { "local", "order", "group", "alphanum", "mod" },
            ---@type number|fun(node: wk.Node):boolean?
            expand = 0, -- expand groups when <= n mappings
            -- expand = function(node)
            --   return not node.desc -- expand all nodes without a description
            -- end,
            -- Functions/Lua Patterns for formatting the labels
            ---@type table<string, ({[1]:string, [2]:string}|fun(str:string):string)[]>
            replace = {
                key = {
                    function(key)
                        return require("which-key.view").format(key)
                    end,
                    -- { "<Space>", "SPC" },
                },
                desc = {
                    { "<Plug>%(?(.*)%)?", "%1" },
                    { "^%+", "" },
                    { "<[cC]md>", "" },
                    { "<[cC][rR]>", "" },
                    { "<[sS]ilent>", "" },
                    { "^lua%s+", "" },
                    { "^call%s+", "" },
                    { "^:%s*", "" },
                },
            },
            icons = {
                breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                separator = "➜", -- symbol used between a key and it's label
                group = "+", -- symbol prepended to a group
                ellipsis = "…",
                -- set to false to disable all mapping icons,
                -- both those explicitly added in a mapping
                -- and those from rules
                mappings = true,
                --- See `lua/which-key/icons.lua` for more details
                --- Set to `false` to disable keymap icons from rules
                ---@type wk.IconRule[]|false
                rules = {},
                -- use the highlights from mini.icons
                -- When `false`, it will use `WhichKeyIcon` instead
                colors = true,
                -- used by key format
                keys = {
                    Up = " ",
                    Down = " ",
                    Left = " ",
                    Right = " ",
                    C = "󰘴 ",
                    M = "󰘵 ",
                    D = "󰘳 ",
                    S = "󰘶 ",
                    CR = "󰌑 ",
                    Esc = "󱊷 ",
                    ScrollWheelDown = "󱕐 ",
                    ScrollWheelUp = "󱕑 ",
                    NL = "󰌑 ",
                    BS = "󰁮",
                    Space = "󱁐 ",
                    Tab = "󰌒 ",
                    F1 = "󱊫",
                    F2 = "󱊬",
                    F3 = "󱊭",
                    F4 = "󱊮",
                    F5 = "󱊯",
                    F6 = "󱊰",
                    F7 = "󱊱",
                    F8 = "󱊲",
                    F9 = "󱊳",
                    F10 = "󱊴",
                    F11 = "󱊵",
                    F12 = "󱊶",
                },
            },
            show_help = true, -- show help message on the command line when the popup is visible
            show_keys = true, -- show the currently pressed key and its label as a message in the command line
            -- Disabled by default for Telescope
            disable = {
                buftypes = {},
                filetypes = { "TelescopePrompt" },
            },
            debug = false, -- enable wk.log in the current directory
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
            { "<leader>g", group = "Go to", icon = "👟" },
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
