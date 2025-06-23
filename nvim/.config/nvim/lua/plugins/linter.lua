return {
    {
        {
            "mfussenegger/nvim-lint",
            opts = {
                linters_by_ft = {
                    htmldjango = { "djlint" },
                    fish = { "fish" },
                },
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "shellcheck",
                "shfmt",
                "flake8",
                "bash-language-server",
                "css-lsp",
                "docker-compose-language-service",
                "dockerfile-language-server",
                "emmet-ls",
                "eslint-lsp",
                "html-lsp",
                "jedi-language-server",
                "json-lsp",
                "lua-language-server",
                "marksman",
                "phpactor",
                "pyright",
                "ruff",
                "rust-analyzer",
                "tailwindcss-language-server",
                "taplo",
                "typescript-language-server",
                "vtsls",
                "vue-language-server",
                "yaml-language-server",
            },
        },
    },
}
