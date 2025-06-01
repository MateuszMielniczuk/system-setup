-- INFO Comment line with gcc
-- Helps with commenting out lines of code

return {
    "numToStr/Comment.nvim",
    opts = {
        -- add any options here
    },
    event = { "BufReadPre", "BufNewFile" },
    -- config = true, -- runs require("Comment").setup()
    config = function()
        require("Comment").setup({
            pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })
    end,
}
