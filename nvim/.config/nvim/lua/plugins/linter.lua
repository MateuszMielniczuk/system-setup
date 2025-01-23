-- INFO: Linter configuration
--

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        local mypy = lint.linters.mypy
        mypy.args = {
            "--show-column-numbers",
            "--hide-error-codes",
            "--hide-error-context",
            "--no-color-output",
            "--no-error-summary",
            "--no-pretty",
            "--ignore-missing-imports",
            "--disallow-untyped-defs",
            "--strict",
        }

        local pylint = lint.linters.pylint
        pylint.args = {
            "-f",
            "json",
            "--disable=E0401,C0114,R0913,E1101",
        }

        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            python = { "bandit", "pylint", "flake8", "mypy" },
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({
            "BufReadPost", -- after reading buffer
            "BufWritePost", -- after writing to buffer
            "TextChanged", -- when text is changed
            "InsertLeave", -- after leave insert mode
        }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "<leader>cl", function()
            lint.try_lint()
        end, { desc = "[c]ode [l]int" })
    end,
}
