return {
    -- detect tabstop and shiftwidth automatically ---------------------------
    "tpope/vim-sleuth",

    -- color schemes install -------------------------------------------------
    {
        "navarasu/onedark.nvim",
        priority = 1000,
    },
    -- indentation guidelines ------------------------------------------------
    {
        "lukas-reineke/indent-blankline.nvim",
        lazy = true,
    },

    -- make color definitions colorized in the background --------------------
    {
        "norcalli/nvim-colorizer.lua",
        opts = {},
    },

    -- Git Integration -------------------------------------------------------
    -- Added this plugin -----------------------------------------------------
    {
        "lewis6991/gitsigns.nvim",
    },

    -- comment line with gcc -------------------------------------------------
    {
        "numToStr/Comment.nvim",
        opts = {
            -- add any options here
        },
        lazy = false,
    },

    -- Lualine ---------------------------------------------------------------
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- pair brackets automatically -------------------------------------------
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {}, -- this is equalent to setup({}) function
    },

    -- LSP Support -----------------------------------------------------------
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- lsp's manager auto install and manage lsp's
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",

            { "hrsh7th/cmp-nvim-lsp" }, -- Autocompletion
            "folke/neodev.nvim", -- add nvim namespace to lsp
        },
    },

    -- Autocompletion --------------------------------------------------------
    {
        "hrsh7th/nvim-cmp",
        -- event = 'InsertEnter',
        dependencies = {
            { "L3MON4D3/LuaSnip" },
        },
    },

    -- Linting ---------------------------------------------------------------
    {
        "mfussenegger/nvim-lint",
        event = "VeryLazy",
    },

    -- Formatter -------------------------------------------------------------
    {
        "mhartington/formatter.nvim",
        event = "VeryLazy",
    },

    -- Telescope (Fuzzy Finder) ----------------------------------------------
    -- Added these plugins to install Telescope ------------------------------
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        lazy = true,
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
    },

    -- better color highlighting for many languages --------------------------
    {
        "nvim-treesitter/nvim-treesitter",
        -- dependencies = {
        --     'nvim-treesitter/nvim-treesitter-textobjects',
        -- },
        build = ":TSUpdate",
    },

    -- which key -------------------------------------------------------------
    -- displays a popup with possible key bindings ---------------------------
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
    },
}
