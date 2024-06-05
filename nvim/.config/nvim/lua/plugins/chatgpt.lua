-- INFO: Library for OpenAI ChatGPT API
-- Allowing to modify code, explain code, fix bugs, optimize code, add tests, add docstrings, autocomplete code and more.

return {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local WELCOME_MESSAGE = "Hello Mateusz.."
        local LOADING_MESSAGE = "I am thinking, give me some time please.."

        require("chatgpt").setup({
            api_key_cmd = "pass show api/chatgpt",
            yank_register = "+",
            edit_with_instructions = {
                diff = false,
                keymaps = {
                    close = "<C-c>",
                    accept = "<C-y>",
                    toggle_diff = "<C-d>",
                    toggle_settings = "<C-o>",
                    cycle_windows = "<Tab>",
                    use_output_as_input = "<C-i>",
                },
            },
            chat = {
                welcome_message = WELCOME_MESSAGE,
                loading_text = LOADING_MESSAGE,
                question_sign = "?",
                answer_sign = "ﮧ",
                max_line_length = 120,
                keymaps = {
                    close = { "<C-c>" },
                    yank_last = "<C-y>",
                    yank_last_code = "<C-p>",
                    scroll_up = "<C-k>",
                    scroll_down = "<C-j>",
                    new_session = "<C-n>",
                    cycle_windows = "<Tab>",
                    cycle_modes = "<C-f>",
                    select_session = "<Space>",
                    rename_session = "r",
                    delete_session = "d",
                    draft_message = "<C-d>",
                    toggle_settings = "<C-o>",
                    toggle_message_role = "<C-r>",
                    toggle_system_role_open = "<C-s>",
                    stop_generating = "<C-x>",
                },
            },
            popup_input = {
                prompt = "  ",
                border = {
                    highlight = "FloatBorder",
                    style = "rounded",
                    text = {
                        top_align = "center",
                        top = " Prompt ",
                    },
                },
                win_options = {
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
                submit = "<C-Enter>",
                submit_n = "<Enter>",
                max_visible_lines = 20,
            },
            openai_params = {
                model = "gpt-3.5-turbo",
                -- frequency_penalty = 0,
                -- presence_penalty = 0,
                max_tokens = 2000,
                -- temperature = 0,
                -- top_p = 1,
                -- n = 1,
            },
            -- openai_edit_params = {
            --     model = "code-davinci-edit-001",
            --     temperature = 0,
            --     top_p = 1,
            --     n = 1,
            -- },
            -- actions_paths = {
            -- "~/.config/nvim/lua/plugins/chatgpt/actions.json"
            -- },
            -- show_quickfixes_cmd = "Trouble quickfix",
            -- predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
        })

        vim.keymap.set(
            "n",
            "<leader>aa",
            "<cmd>ChatGPTCompleteCode<CR>",
            { desc = "[a]i [a]utocomplete code" }
        )
        vim.keymap.set(
            "n",
            "<leader>ac",
            "<cmd>ChatGPT<CR>",
            { desc = "[a]i [c]hatgpt prompt open" }
        )
        -- actions run on code
        vim.keymap.set(
            "n",
            "<leader>ad",
            "<cmd>ChatGPTRun docstring<CR>",
            { desc = "[a]i [d]ocstring add" }
        )
        vim.keymap.set(
            "n",
            "<leader>ae",
            "<cmd>ChatGPTRun explain_code<CR>",
            { desc = "[a]i [e]xplain code" }
        )
        vim.keymap.set(
            "n",
            "<leader>af",
            "<cmd>ChatGPTRun fix_bugs<CR>",
            { desc = "[a]i [f]ix bugs" }
        )
        vim.keymap.set(
            "n",
            "<leader>am",
            "<cmd>ChatGPTEditWithInstructions<CR>",
            { desc = "[a]i [m]odify code with instructions" }
        )
        vim.keymap.set(
            "n",
            "<leader>ao",
            "<cmd>ChatGPTRun optimize_code<CR>",
            { desc = "[a]i [o]ptimize code" }
        )
        -- act as pretend to be eg linux terminal or js interpreter
        vim.keymap.set(
            "n",
            "<leader>ap",
            "<cmd>ChatGPTActAs<cr>",
            { desc = "[a]i [p]retend to be ..." }
        )
        vim.keymap.set(
            "n",
            "<leader>at",
            "<cmd>ChatGPTRun add_tests<CR>",
            { desc = "[a]i [t]ests add" }
        )
    end,
}
