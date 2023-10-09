-- color schemes install -------------------------------------------------
return {
    "navarasu/onedark.nvim",
    priority = 1000,

    config = function()
        vim.o.background = "dark"
        require("onedark").setup({
            style = "warmer",
            transparent = true,
            term_colors = true,
        })
        require("onedark").load()
    end,
}
