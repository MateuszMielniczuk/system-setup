-- make color definitions colorized in the background --------------------
return {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    config = function()
        -- Attaches to every FileType mode
        require("colorizer").setup()

        -- Attach to certain Filetypes, add special configuration for `html`
        -- Use `background` for everything else.
        -- require 'colorizer'.setup {
        --   'css';
        --   'javascript';
        --   html = {
        --     mode = 'background';
        --   }
        -- }
    end,
}
