-- Telescope (Fuzzy Finder) ----------------------------------------------
-- Added these plugins to install Telescope ------------------------------
return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        telescope.setup({
            defaults = {
                -- Default configuration for telescope goes here:
                -- config_key = value,

                prompt_prefix = " ",
                selection_caret = " ",
                path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-d>"] = actions.cycle_history_next,
                        ["<C-u>"] = actions.cycle_history_prev,

                        -- ["<C-j>"] = actions.move_selection_next,
                        -- ["<C-k>"] = actions.move_selection_previous,

                        -- ["<C-c>"] = actions.close,

                        -- ["<Down>"] = actions.move_selection_next,
                        -- ["<Up>"] = actions.move_selection_previous,

                        -- ["<CR>"] = actions.select_default,
                        -- ["<C-x>"] = actions.select_horizontal,
                        -- ["<C-v>"] = actions.select_vertical,
                        -- ["<C-t>"] = actions.select_tab,

                        ["<C-j>"] = actions.preview_scrolling_up,
                        ["<C-k>"] = actions.preview_scrolling_down,

                        ["<PageUp>"] = actions.results_scrolling_up,
                        ["<PageDown>"] = actions.results_scrolling_down,

                        -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                        -- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                        -- ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        -- ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        -- ["<C-l>"] = actions.complete_tag,
                        ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
                    },

                    n = {
                        ["<esc>"] = actions.close,
                        -- ["<CR>"] = actions.select_default,
                        -- ["<C-x>"] = actions.select_horizontal,
                        -- ["<C-v>"] = actions.select_vertical,
                        -- ["<C-t>"] = actions.select_tab,

                        -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                        -- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                        -- ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        -- ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                        -- ["H"] = actions.move_to_top,
                        -- ["M"] = actions.move_to_middle,
                        -- ["L"] = actions.move_to_bottom,

                        ["<Down>"] = actions.move_selection_next,
                        ["<Up>"] = actions.move_selection_previous,
                        ["gg"] = actions.move_to_top,
                        ["G"] = actions.move_to_bottom,

                        ["<C-j>"] = actions.preview_scrolling_up,
                        ["<C-k>"] = actions.preview_scrolling_down,

                        ["<PageUp>"] = actions.results_scrolling_up,
                        ["<PageDown>"] = actions.results_scrolling_down,

                        ["?"] = actions.which_key,
                    },
                },
            },
            pickers = {
                -- Default configuration for builtin pickers goes here:
                -- picker_name = {
                --   picker_config_ key = value,
                --   ...
                -- }
                -- Now the picker_config_key will be applied every time you call this
                -- builtin picker
            },
            extensions = {
                -- Your extension configuration goes here:
                -- extension_name = {
                --   extension_config_key = value,
                -- }
                -- please take a look at the readme of the extension you want to configure
            },
        })

        telescope.load_extension("fzf")

        -- KEYMAPS --------------------------------------------------------
        -- See `:help telescope.builtin`
        -- ----------------------------------------------------------------
        vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, {
            desc = "[?] Find recently opened files",
        })
        vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, {
            desc = "[ ] Find existing buffers",
        })
        vim.keymap.set("n", "<leader>/", function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require("telescope.builtin").current_buffer_fuzzy_find(
                require("telescope.themes").get_dropdown({
                    winblend = 10,
                    previewer = false,
                })
            )
        end, { desc = "[/] Fuzzy search current buffer" })

        -- vim.keymap.set(
        --     "n",
        --     "<leader>gf",
        --     require("telescope.builtin").git_files,
        --     { desc = "Search [g]it [f]iles" }
        -- )

        vim.keymap.set(
            "n",
            "<leader>sc",
            require("telescope.builtin").colorscheme,
            { desc = "[s]earch [c]olorscheme" }
        )
        vim.keymap.set(
            "n",
            "<leader>sd",
            require("telescope.builtin").diagnostics,
            { desc = "[s]earch [d]iagnostics" }
        )
        vim.keymap.set(
            "n",
            "<leader>sf",
            "<cmd>Telescope find_files hidden=true<cr>",
            { desc = "[s]earch [f]iles" }
        )
        vim.keymap.set(
            "n",
            "<leader>sg",
            require("telescope.builtin").live_grep,
            { desc = "[s]earch [g]rep (word globally)" }
        )
        vim.keymap.set(
            "n",
            "<leader>sh",
            require("telescope.builtin").help_tags,
            { desc = "[s]earch [h]elp tags" }
        )
        vim.keymap.set(
            "n",
            "<leader>sk",
            require("telescope.builtin").keymaps,
            { desc = "[s]earch [k]eymaps" }
        )
        vim.keymap.set(
            "n",
            "<leader>sm",
            require("telescope.builtin").man_pages,
            { desc = "[s]earch [m]an pages" }
        )
        vim.keymap.set(
            "n",
            "<leader>sr",
            require("telescope.builtin").resume,
            { desc = "[s]earch keymaps res[u]me" }
        )
        vim.keymap.set(
            "n",
            "<leader>sw",
            require("telescope.builtin").grep_string,
            { desc = "[s]earch current [w]ord" }
        )
    end,
}
