-- INFO: Mason is a package manager for neovim.
-- It is a plugin that allows you to install and manage language servers,
-- formatters, linters, debuggers and other tools for neovim.

return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        -- import mason
        local mason = require("mason")

        -- import mason-lspconfig
        local mason_lspconfig = require("mason-lspconfig")

        -- import mason_tool_installer
        local mason_tool_installer = require("mason-tool-installer")

        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            ensure_installed = {
                -- list of lsp servers to be installed automatically by mason
                "bashls", -- bash lsp
                "cssls",
                "emmet_ls", -- shortcuts for html, css generation
                "graphql",
                "html",
                "jedi_language_server", --python lsp
                "lua_ls",
                "rust_analyzer", --rust lsp
                "ruff", --python all in one
                "ts_ls", --typescript lsp
            },
            -- auto-install configured servers (with lspconfig)
            automatic_installation = true, -- not the same as ensure_installed
        })

        mason_tool_installer.setup({
            ensure_installed = {
                -- auto install formatters, linters and debuggers if not installed
                "black", -- formatter for python
                "debugpy", -- debugger for python
                "eslint_d", -- js linter
                -- "flake8", -- linter for python - install locally
                "isort", -- formatter sort imports for python
                "js-debug-adapter", -- debugger for js
                "mypy", -- linter for python - tyging - install locally
                "prettier", -- formatter for js, ts etc
                "pylint", -- code linter for python - install locally
                "ruff",
                "stylua", -- formatter for lua
            },
        })
    end,
}
