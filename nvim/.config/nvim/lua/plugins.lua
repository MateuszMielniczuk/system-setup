return {
    -- colorschemes install --------------------------------------------------
    {
        'navarasu/onedark.nvim',
        priority = 999,
    },
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000
    },
    -- indentation guidelines
    {
        "lukas-reineke/indent-blankline.nvim",
        lazy = true,
    },
    -- comment line with gcc
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
        lazy = false,
    },
    -- Lualine ---------------------------------------------------------------
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },

    -- Language Support
    -- Added this plugin.
    -- {
    --     {
    --         'VonHeikemen/lsp-zero.nvim',
    --         branch = 'dev-v3',
    --         lazy = true,
    --         config = false,
    --         init = function()
    --             -- Disable automatic setup, we are doing it manually
    --             vim.g.lsp_zero_extend_cmp = 0
    --             vim.g.lsp_zero_extend_lspconfig = 0
    --         end,
    --     },

    --     --- Uncomment these if you want to manage LSP servers from neovim
    --     { 'williamboman/mason.nvim', lazy = false, config = true, },
    --     { 'williamboman/mason-lspconfig.nvim' },

    --     -- LSP Support
    --     {
    --         'neovim/nvim-lspconfig',
    --         cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    --         event = { 'BufReadPre', 'BufNewFile' },
    --         dependencies = {
    --             { 'hrsh7th/cmp-nvim-lsp' },
    --             { 'williamboman/mason-lspconfig.nvim' },
    --             'folke/neodev.nvim', -- add nvim namespace to lsp
    --         },
    --     },

    --     -- Autocompletion
    --     {
    --         'hrsh7th/nvim-cmp',
    --         -- event = 'InsertEnter',
    --         dependencies = {
    --             { 'L3MON4D3/LuaSnip' },
    --         },
    --     }
    -- },

    -- LSP Support
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- lsp's manager auto install and manage lsp's
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',
      
            { 'hrsh7th/cmp-nvim-lsp' },
            'folke/neodev.nvim',     -- add nvim namespace to lsp
        },
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        -- event = 'InsertEnter',
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
        },
    },


    -- Nvimtree (File Explorer) ----------------------------------------------
    -- {
    --     'nvim-tree/nvim-tree.lua',
    --     lazy = true,
    --     dependencies = {
    --         'nvim-tree/nvim-web-devicons',
    --     },
    -- },
    -- Telescope (Fuzzy Finder)
    -- Added these plugins to install Telescope
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        lazy = true,
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
        }
    },
    -- better color highlighting for many languages
    {
        'nvim-treesitter/nvim-treesitter',
        -- dependencies = {
        --     'nvim-treesitter/nvim-treesitter-textobjects',
        -- },
        -- build = ':TSUpdate',
    },
    -- which key -------------------------------------------------------------
    -- displays a popup with possible key bindings
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
    },
}
