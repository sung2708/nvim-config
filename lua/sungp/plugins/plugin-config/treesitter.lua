local M = require("sungp.helper.utils")

return {
    {
    "nvim-treesitter/nvim-treesitter",
    -- Sử dụng branch master để đảm bảo tương thích tốt nhất
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
        local configs = M.safe_require("nvim-treesitter.configs")
        if not configs then return end

        configs.setup({
            sync_install = false,
            auto_install = true,

            -- 2. Main features
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },

            -- 3. Textobjects (Consolidate all keybinding logic here)
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj if cursor is not inside it
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["as"] = { query = "@local.scope", query_group = "locals" },
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>a"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>A"] = "@parameter.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- Add to jump list to use Ctrl-O/I
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer",
                        ["]o"] = { query = { "@loop.inner", "@loop.outer" } },
                        ["]s"] = { query = "@local.scope", query_group = "locals" },
                        ["]z"] = { query = "@fold", query_group = "folds" },
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer",
                    },
                    -- Move to next/previous conditional (if-else-elseif)
                    goto_next = {
                        ["]d"] = "@conditional.outer",
                    },
                    goto_previous = {
                        ["[d"] = "@conditional.outer",
                    },
                },
            },
        })
    end,
    },
}