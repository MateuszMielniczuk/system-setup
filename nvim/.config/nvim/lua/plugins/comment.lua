-- INFO Comment line with gcc
-- Helps with commenting out lines of code

return {
    "numToStr/Comment.nvim",
    opts = {
        -- add any options here
    },
    event = { "BufReadPre", "BufNewFile" },
    config = true, -- runs require("Comment").setup()
}
