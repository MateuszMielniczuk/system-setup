-- Autocompletion --------------------------------------------------------
return {
    "hrsh7th/nvim-cmp",
    -- this event loads cmp only when being used
    event = "InsertEnter",
    dependencies = {
        {
            "L3MON4D3/LuaSnip", -- add snippet engine
            "hrsh7th/cmp-path", -- source for file system paths
            "hrsh7th/cmp-buffer", --source for text in buffer
        },
    },
    config = function()
        -- [[ Configure nvim-cmp ]]
        -- See `:help cmp`

        local cmp = require("cmp")

        local luasnip = require("luasnip")

        -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
        -- require("luasnip.loaders.from_vscode").lazy_load()

        luasnip.config.setup({})

        cmp.setup({
            -- REQUIRED - you must specify a snippet engine
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            -- completion = {
            -- completeopt = "menu,menuone,preview,noselect",
            -- },
            -- window = {
            -- completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
            -- },
            mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete({}),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- scroll documentation
                ["<C-d>"] = cmp.mapping.scroll_docs(4), -- scroll documentation
                ["C-c"] = cmp.mapping.abort(), -- close completion window
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = {
                { name = "nvim_lsp", group_index = 2 },
                { name = "luasnip", group_index = 2 },

                { name = "buffer", group_index = 2 }, -- text within current buffer
                { name = "path", group_index = 2 }, -- file system paths
            },
        })
    end,
}
