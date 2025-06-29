local has_words_before = function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
        return false
    end
    local line = vim.api.nvim_get_current_line()
    return line:sub(col, col):match("%s") == nil
end
return {
    {
        "saghen/blink.cmp",
        opts = {

            -- in your blink configuration
            keymap = {
                preset = "enter",
                ["CR"] = { "select_and_accept" },

                -- If completion hasn't been triggered yet, insert the first suggestion; if it has, cycle to the next suggestion.
                ["<Tab>"] = {
                    function(cmp)
                        if has_words_before() then
                            return cmp.insert_next()
                        end
                    end,
                    "fallback",
                },
                -- Navigate to the previous suggestion or cancel completion if currently on the first one.
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            },
            completion = {
                list = { selection = { preselect = false }, cycle = { from_top = false } },
            },
        },
    },
}
