return {

    -- which key -------------------------------------------------------------
    -- displays a popup with possible key bindings
    {
        "folke/which-key.nvim",
        lazy = true,
    },
    -- colorschemes install --------------------------------------------------
    {
        'navarasu/onedark.nvim',
        priority = 1000,
    },
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000
    },
    -- Lualine ---------------------------------------------------------------
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    -- Nvimtree (File Explorer) ----------------------------------------------
    {
        'nvim-tree/nvim-tree.lua',
        lazy = true,
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
    },
}
