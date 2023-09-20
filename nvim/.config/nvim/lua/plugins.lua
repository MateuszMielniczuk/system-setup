return {
    -- detect tabstop and shiftwidth automatically ---------------------------
    'tpope/vim-sleuth',

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
    {
        'norcalli/nvim-colorizer.lua',
        opts = {},
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
    {
        'windwp/nvim-autopairs',
	event = "InsertEnter",
	opts = {} -- this is equalent to setup({}) function
    },
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
        build = ':TSUpdate',
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
