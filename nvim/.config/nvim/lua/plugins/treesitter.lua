-- INFO: Better color highlighting for many languages
-- Enables better syntax highlighting for many languages and
-- unlocks many text objects and motions for those languages.
-- This plugin is extendible with other plugins that add more
-- text objects and motions.

return {
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "windwp/nvim-ts-autotag", -- autoclosing tags
        },
        build = ":TSUpdate",

        config = function()
            require("nvim-treesitter.configs").setup({
                -- Add a language of your choice
                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = false,
                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,
                ignore_install = { "all" }, -- List of parsers to ignore installing
                highlight = {
                    enable = true, -- false will disable the whole extension
                    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
                    disable = function(_, buf)
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = false, disable = { "yaml" } },
                modules = {},
                ensure_installed = {
                    "bash",
                    "c",
                    "css",
                    "cpp",
                    "dockerfile",
                    "gitignore",
                    "go",
                    "graphql",
                    "html",
                    "json",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "rust",
                    "tsx",
                    "javascript",
                    "typescript",
                    "vimdoc",
                    "vim",
                    "vimdoc",
                    "yaml",
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,

                        -- Automatically jump to textobjects
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["a="] = {
                                query = "@assignment.outer",
                                desc = "Select outer part of an assignment",
                            },
                            ["i="] = {
                                query = "@assignment.inner",
                                desc = "Select inner part of an assignment",
                            },
                            ["l="] = {
                                query = "@assignment.lhs",
                                desc = "Select left hand side of an assignment",
                            },
                            ["r="] = {
                                query = "@assignment.rhs",
                                desc = "Select right hand side of an assignment",
                            },

                            ["aa"] = {
                                query = "@parameter.outer",
                                desc = "Select outer part of a parameter/argument",
                            },
                            ["ia"] = {
                                query = "@parameter.inner",
                                desc = "Select inner part of a parameter/argument",
                            },

                            ["ai"] = {
                                query = "@conditional.outer",
                                desc = "Select outer part of a conditional",
                            },
                            ["ii"] = {
                                query = "@conditional.inner",
                                desc = "Select inner part of a conditional",
                            },

                            ["al"] = {
                                query = "@loop.outer",
                                desc = "Select outer part of a loop",
                            },
                            ["il"] = {
                                query = "@loop.inner",
                                desc = "Select inner part of a loop",
                            },

                            ["aF"] = {
                                query = "@call.outer",
                                desc = "Select outer part of a function call",
                            },
                            ["iF"] = {
                                query = "@call.inner",
                                desc = "Select inner part of a function call",
                            },

                            ["af"] = {
                                query = "@function.outer",
                                desc = "Select outer part of a method/function definition",
                            },
                            ["if"] = {
                                query = "@function.inner",
                                desc = "Select inner part of a method/function definition",
                            },

                            ["ac"] = {
                                query = "@class.outer",
                                desc = "Select outer part of a class",
                            },
                            ["ic"] = {
                                query = "@class.inner",
                                desc = "Select inner part of a class",
                            },
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]F"] = {
                                query = "@call.outer",
                                desc = "Next function call start",
                            },
                            ["]f"] = {
                                query = "@function.outer",
                                desc = "Next method/function def start",
                            },
                            ["]c"] = { query = "@class.outer", desc = "Next class start" },
                            ["]i"] = {
                                query = "@conditional.outer",
                                desc = "Next conditional start",
                            },
                            ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

                            -- You can pass a query group to use query from
                            -- `queries/<lang>/<query_group>.scm file in your runtime path.
                            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`.
                            -- They also provide highlights.scm and indent.scm.
                            ["]s"] = {
                                query = "@scope",
                                query_group = "locals",
                                desc = "Next scope",
                            },
                            ["]z"] = {
                                query = "@fold",
                                query_group = "folds",
                                desc = "Next fold",
                            },
                        },
                        goto_previous_start = {
                            ["[F"] = {
                                query = "@call.outer",
                                desc = "Prev function call start",
                            },
                            ["[f"] = {
                                query = "@function.outer",
                                desc = "Prev method/function def start",
                            },
                            ["[c"] = { query = "@class.outer", desc = "Prev class start" },
                            ["[i"] = {
                                query = "@conditional.outer",
                                desc = "Prev conditional start",
                            },
                            ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
                        },
                    },
                },
            })
        end,
    },
}
