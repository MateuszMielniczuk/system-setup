-- LSP configuration ---------------------------------------------------------
--
-- KEYBINDINGS ---------------------------------------------------------------
------------------------------------------------------------------------------

local custom_on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { desc = desc })
    end

    nmap(
        '<leader>rn',
        vim.lsp.buf.rename,
        '[R]e[n]ame'
    )
    nmap(
        '<leader>ca',
        vim.lsp.buf.code_action,
        '[C]ode [A]ction'
    )

    nmap(
        'gd',
        vim.lsp.buf.definition,
        '[G]oto [D]efinition'
    )
    nmap(
        'gr',
        require('telescope.builtin').lsp_references,
        '[G]oto [R]eferences'
    )
    nmap(
        'gI',
        vim.lsp.buf.implementation,
        '[G]oto [I]mplementation'
    )
    nmap(
        '<leader>D',
        vim.lsp.buf.type_definition,
        'Type [D]efinition'
    )
    nmap(
        '<leader>ds',
        require('telescope.builtin').lsp_document_symbols,
        '[D]ocument [S]ymbols'
    )
    nmap(
        '<leader>ws',
        require('telescope.builtin').lsp_dynamic_workspace_symbols,
        '[W]orkspace [S]ymbols'
    )

    -- See `:help K` for why this keymap
    nmap(
        'K',
        vim.lsp.buf.hover,
        'Hover Documentation'
    )
    nmap(
        '<C-k>',
        vim.lsp.buf.signature_help,
        'Signature Documentation'
    )

    -- Lesser used LSP functionality
    nmap(
        'gD',
        vim.lsp.buf.declaration,
        '[G]oto [D]eclaration'
    )
    nmap(
        '<leader>wa',
        vim.lsp.buf.add_workspace_folder,
        '[W]orkspace [A]dd Folder'
    )
    nmap(
        '<leader>wr',
        vim.lsp.buf.remove_workspace_folder,
        '[W]orkspace [R]emove Folder'
    )
    nmap(
        '<leader>wl',
        function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end,
        '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- error messages navigation and popups
vim.api.nvim_set_keymap(
    'n',
    '<leader>do',
    '<cmd>lua vim.diagnostic.open_float()<CR>',
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
    'n',
    '<leader>d[',
    '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
    'n',
    '<leader>d]',
    '<cmd>lua vim.diagnostic.goto_next()<CR>',
    { noremap = true, silent = true })

-- telescope plugin config
vim.api.nvim_set_keymap(
    'n',
    '<leader>dd',
    '<cmd>Telescope diagnostics<CR>',
    { noremap = true, silent = true }
)

-- nvim-cmp supports additional completion capabilities
-- so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local lspconfig = require("lspconfig")

-- Setup neovim lua configuration
require('neodev').setup() -- nvim namespace config

-- Ensure the servers configured below are installed by mason
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup({
    ensure_installed = {
        'bashls',               -- bash
        'lua_ls',
        'jedi_language_server', --python
        'pylsp',                -- python language servers
        -- run this command if pylsp installed:
        -- :PylspInstall pyls-flake8 pylsp-mypy pyls-isort
        'tsserver',             --typescript
        'ruff_lsp',             -- check errors in python code
        'rust_analyzer',        --rust
    },
})

lspconfig.bashls.setup {
    on_attach = custom_on_attach,
    capabilities = capabilities,
}

lspconfig.pylsp.setup {
    on_attach = custom_on_attach,
    settings = {
        -- ruff_lsp = { enabled = true },
        pylsp = {
            plugins = {
                -- formatter options
                black = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                -- linter options
                pylint = { enabled = true, executable = "pylint" },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                -- type checker
                pylsp_mypy = { enabled = true },
                -- auto-completion options
                jedi_completion = { fuzzy = true },
                -- import sorting
                pyls_isort = { enabled = true },
                ruff_lsp = { enabled = true },
            },
        },
    },
    flags = {
        debounce_text_changes = 200,
    },
    capabilities = capabilities,
}

-- lspconfig.ruff_lsp.setup {
--     on_attach = custom_on_attach,
--     capabilities = capabilities,
--     filetypes = { 'python' },
-- }

lspconfig.jedi_language_server.setup {
    on_attach = custom_on_attach,
    capabilities = capabilities,
    filetypes = { 'python' },
}

lspconfig.tsserver.setup {
    on_attach = custom_on_attach,
    capabilities = capabilities,
}

lspconfig.lua_ls.setup {
    on_attach = custom_on_attach,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = false,
                --   -- Make the server aware of Neovim runtime files,
                --   -- see also https://github.com/LuaLS/lua-language-server/wiki/Libraries#link-to-workspace .
                --   -- Lua-dev.nvim also has similar settings for lua ls, https://github.com/folke/neodev.nvim/blob/main/lua/neodev/luals.lua .
                --   library = {
                --     vim.fn.stdpath("data") .. "/lazy/emmylua-nvim",
                --     vim.fn.stdpath("config"),
                --   },
                maxPreload = 2000,
                preloadFileSize = 50000,
            },
            telemetry = { enable = false },
        },
    },
    capabilities = capabilities,
}
