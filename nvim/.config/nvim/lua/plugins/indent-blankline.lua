-- indentation guidelines ------------------------------------------------
return {
    "lukas-reineke/indent-blankline.nvim",
    -- lazy = true,
    main = "ibl",
    opts = {},
    config = function()
        -- local highlight = {
        --     "CursorColumn",
        --     "Whitespace",
        -- }

        require("ibl").setup({
            whitespace = {
                -- highlight = highlight,
                remove_blankline_trail = false,
            },
        })
    end,
}
