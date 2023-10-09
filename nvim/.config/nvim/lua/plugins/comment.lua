-- comment line with gcc -------------------------------------------------
return {
    "numToStr/Comment.nvim",
    opts = {
        -- add any options here
    },
    event = { "BufReadPre", "BufNewFile" },
    config = true, -- runs require("Comment").setup()
}
