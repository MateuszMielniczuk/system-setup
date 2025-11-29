return {
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                htmldjango = { "djlint" },
                fish = { "fish" },
            },
        },
    },
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "bash-language-server",
                "css-lsp",
                "docker-compose-language-service",
                "dockerfile-language-server",
                "emmet-ls", -- for html and css
                "eslint-lsp", -- js/ts linter
                "flake8", -- python linter
                "html-lsp",
                "jedi-language-server", -- python language server
                "json-lsp",
                "lua-language-server",
                "marksman", -- markdown linter
                "mmdc", -- mermaid cli
                "phpactor", -- php language server
                "pyright", -- python language server
                "ruff", -- python linter
                "rust-analyzer",
                "shellcheck", -- shell script linter
                "shfmt", -- shell script formatter
                "stylua", -- lua formatter
                "tailwindcss-language-server", -- tailwindcss lsp
                "taplo", -- toml lsp
                "tectonic", -- markdown compiler
                "typescript-language-server",
                "vtsls", -- ts/js language server
                "vue-language-server", -- vue lsp
                "yaml-language-server", -- yaml lsp
            },
        },
    },
}
