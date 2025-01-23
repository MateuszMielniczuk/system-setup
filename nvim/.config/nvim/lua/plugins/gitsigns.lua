-- INFO: Git Integration inside Neovim
--

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        -- git-config.lua
        local icons = require("core.icons")

        local status_ok, gitsigns = pcall(require, "gitsigns")
        if not status_ok then
            return
        end

        gitsigns.setup({
            signs = {
                add = { text = icons.git.LineAdded },
                change = { text = icons.git.LineModified },
                delete = { text = icons.git.LineRemoved },
                topdelete = { text = icons.git.FileDeleted },
                changedelete = { text = icons.git.LineModified },
                untracked = { text = "┆" },
            },
            signs_staged = {
                add = { text = icons.git.LineAdded },
                change = { text = icons.git.LineModified },
                delete = { text = icons.git.LineRemoved },
                topdelete = { text = icons.git.FileDeleted },
                changedelete = { text = icons.git.LineModified },
                untracked = { text = "┆" },
            },
            signs_staged_enable = true,
            signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
            numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                interval = 1000,
                follow_files = true,
            },
            auto_attach = true,
            attach_to_untracked = true,
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true,
            },
            current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 40000,
            preview_config = {
                -- Options passed to nvim_open_win
                border = "single",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
            },
            on_attach = function(bufnr)
                vim.keymap.set(
                    "n",
                    "<leader>gp",
                    require("gitsigns").prev_hunk,
                    { buffer = bufnr, desc = "[g]o to [p]revious hunk" }
                )
                vim.keymap.set(
                    "n",
                    "<leader>gn",
                    require("gitsigns").next_hunk,
                    { buffer = bufnr, desc = "[g]o to [n]ext hunk" }
                )
                vim.keymap.set(
                    "n",
                    "<leader>hh",
                    require("gitsigns").preview_hunk,
                    { buffer = bufnr, desc = "[h]oover [h]unk" }
                )
            end,
        })
    end,
}
