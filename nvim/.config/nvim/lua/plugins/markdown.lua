return {
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters = {
                ["markdownlint-cli2"] = {
                    args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint.yaml" },
                },
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            preset = "obsidian",
            heading = {
                sign = false,
                width = "full",
                left_pad = 1,
                icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
            },
            code = {
                sign = false,
                width = "block",
                left_pad = 2,
                right_pad = 4,
                border = "thick",
            },
            bullet = { icons = { "•", "◦", "▸", "▹" } },
            pipe_table = { preset = "round" },
            quote = { repeat_linebreak = true },
            latex = { enabled = false },
            anti_conceal = {
                ignore = { code_background = true, indent = true, sign = true, virtual_lines = true, table_border = { "n", "v" } },
            },
        },
    },
    {
        "folke/snacks.nvim",
        opts = { image = { enabled = true } },
    },
}
