-- INFO: Highlight all instances of the word under the cursor
--

return {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        delay = 100,
        filetypes_denylist = {
            "mason",
            "harpoon",
            "neo-tree",
            "DressingInput",
            "NeogitCommitMessage",
            "qf",
            "dirvish",
            "fugitive",
            "alpha",
            "NvimTree",
            "lazy",
            "Trouble",
            "netrw",
            "lir",
            "DiffviewFiles",
            "Outline",
            "Jaq",
            "spectre_panel",
            "toggleterm",
            "DressingSelect",
            "TelescopePrompt",
        },
    },
    lazy = false,
    config = function(_, opts)
        require("illuminate").configure(opts)

        vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
        vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
        vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })

        vim.api.nvim_create_autocmd({ "ColorScheme" }, {
            pattern = { "*" },
            callback = function(_)
                vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
                vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
                vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
            end,
        })
    end,
}
