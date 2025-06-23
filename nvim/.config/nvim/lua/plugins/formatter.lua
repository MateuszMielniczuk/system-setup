return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                css = { "prettier" },
                html = { "prettier" },
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                json = { "prettier" },
                lua = { "stylua" },
                markdown = { "prettier" },
                python = { "black", "isort" },
                sh = { "shfmt" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                yaml = { "prettier" },
                htmldjango = { "djlint" },
            },
            formatters = {
                djlint = {
                    args = { "--reformat", "-" },
                    cwd = require("conform.util").root_file({
                        ".djlintrc",
                    }),
                },
            },
        },
    },
}
