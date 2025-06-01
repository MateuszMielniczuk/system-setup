-- Helping with comments for tsx and jsx files and also VUE
return {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "VeryLazy",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("ts_context_commentstring").setup({
        enable = true,
        enable_autocmd = false,
        })
    end,
}
