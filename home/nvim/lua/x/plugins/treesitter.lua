require("lz.n").load {
    {
        "nvim-ts-autotag",
        event = "DeferredUIEnter",
        after = function() end,
    },
    {
        "nvim-treesitter-endwise",
        event = "DeferredUIEnter",
    },
    {
        "nvim-treesitter-textobjects",
        event = "DeferredUIEnter",
        after = function()
            require("nvim-treesitter.configs").setup {
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            -- You can optionally set descriptions to the mappings (used in the desc parameter of
                            -- nvim_buf_set_keymap) which plugins like which-key display
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                            -- You can also use captures from other query groups like `locals.scm`
                            ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                        },
                    },
                },
            }
        end,
    },
}
