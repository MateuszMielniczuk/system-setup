-- INFO: Dressing is a Neovim plugin that provides a set of utilities
-- for creating and managing UI components.

return {
    "stevearc/dressing.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
    config = function()
        require("dressing").setup()
    end,
}
