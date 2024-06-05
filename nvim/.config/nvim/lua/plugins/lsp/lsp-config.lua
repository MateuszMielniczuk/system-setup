-- INFO: LSP configuration for neovim
--

return {
    "neovim/nvim-lspconfig",
    -- load only when opening or creating new buffer
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp" }, -- Autocompletion
        -- "folke/neodev.nvim", -- add nvim namespace to lsp
    },
    config = function()
        local lspconfig = require("lspconfig")

        -- nvim-cmp supports additional completion capabilities
        -- so broadcast that to servers
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

        -- Setup neovim lua configuration
        -- require("neodev").setup() -- nvim namespace config

        -- KEYBINDINGS ------------------------------------------------------

        local custom_on_attach = function(_, bufnr)
            -- NOTE: Remember that lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself
            -- many times.
            local nmap = function(keys, func, desc)
                if desc then
                    desc = "LSP: " .. desc
                end
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
            end

            nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
            nmap("<leader>r", vim.lsp.buf.rename, "[r]ename smart")

            nmap("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")

            nmap(
                "<leader>dk",
                "<cmd>lua vim.diagnostic.goto_prev()<CR>",
                "[d]iagnostics [k]go to previous"
            )
            nmap(
                "<leader>dj",
                "<cmd>lua vim.diagnostic.goto_next()<CR>",
                "[d]iagnostics [j]go to next"
            )

            nmap("<leader>dl", vim.diagnostic.setloclist, "[d]iagnostics [l]ist")

            nmap("<leader>he", vim.diagnostic.open_float, "[h]oover [e]diagnostic floating")
            nmap("<leader>hd", vim.lsp.buf.hover, "[h]over [d]ocumentation")
            nmap("<leader>hs", vim.lsp.buf.signature_help, "[h]over [s]ignature documentation")

            nmap("<leader>gd", vim.lsp.buf.definition, "[g]oto [d]efinition")
            nmap("<leader>gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
            nmap("<leader>gi", vim.lsp.buf.implementation, "[g]oto [i]mplementation")

            nmap("<leader>lr", "<cmd>LspRestart<cr>", "[l]sp [r]estart")
            nmap("<leader>li", "<cmd>LspInfo<cr>", "[l]sp [i]nfo")

            nmap(
                "<leader>si",
                "<cmd>Telescope lsp_implementations<cr>",
                "[s]how/search all [i]mplementations"
            )
            nmap(
                "<leader>ss",
                require("telescope.builtin").lsp_document_symbols,
                "[s]earch [s]ymbols"
            )
            nmap(
                "<leader>sp",
                require("telescope.builtin").lsp_workspace_symbols,
                "[s]earch [p]roject symbols"
            )
            -- nmap(
            --     "<leader>ss",
            --     require("telescope.builtin").lsp_dynamic_workspace_symbols,
            --     "[s]search [s]ymbols in workspace"
            -- )
            -- nmap("<leader>sr", require("telescope.builtin").lsp_references, "[s]earch [r]eferences")
            nmap("<leader>sr", "<cmd>Telescope oldfiles <cr>", "[s]earch [r]ecent files")

            -- See `:help K` for why this keymap
        end

        -- Change the Diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- configure bash language server
        lspconfig.bashls.setup({
            on_attach = custom_on_attach,
            capabilities = capabilities,
        })

        lspconfig.cssls.setup({
            capabilities = capabilities,
            on_attach = custom_on_attach,
        })

        -- configure emmet language server
        lspconfig.emmet_ls.setup({
            capabilities = capabilities,
            on_attach = custom_on_attach,
            filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss" },
        })

        -- configure html server
        lspconfig.html.setup({
            capabilities = capabilities,
            on_attach = custom_on_attach,
        })

        lspconfig.jedi_language_server.setup({
            on_attach = custom_on_attach,
            capabilities = capabilities,
            filetypes = { "python" },
        })

        -- configure lua server (with special settings)
        lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_attach = custom_on_attach,
            settings = { -- custom settings for lua
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        -- (most likely LuaJIT in the case of Neovim)
                        version = "LuaJIT",
                    },
                    -- make the language server recognize "vim" global
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        -- make language server aware of runtime files
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                        maxPreload = 1500,
                        preloadFileSize = 40000,
                    },
                    telemetry = { enable = false },
                },
            },
        })

        lspconfig.tsserver.setup({
            on_attach = custom_on_attach,
            capabilities = capabilities,
        })
    end,
}
