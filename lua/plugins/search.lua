return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            {
                "<leader>ff",
                function()
                    require("fzf-lua").files({
                        file_icons = true,
                        git_icons = true,
                        previewer = "builtin",
                        winopts = {
                            preview = {
                                delay = 100,
                            },
                        },
                    })
                end,
                desc = "Find: Files",
            },
            {
                "<leader>fg",
                function()
                    -- Native live_grep is faster but deliberately disables
                    -- file/git icons. Use the processed provider here so
                    -- file icons remain available.
                    require("fzf-lua").live_grep({
                        file_icons = true,
                        -- Git status would run during every live reload.
                        git_icons = false,
                        previewer = "builtin",
                        winopts = {
                            preview = {
                                delay = 100,
                            },
                        },
                    })
                end,
                desc = "Find: Grep",
            },
            {
                "<leader>fb",
                function()
                    require("fzf-lua").buffers()
                end,
                desc = "Find: Buffers",
            },
            {
                "<leader>fh",
                function()
                    require("fzf-lua").helptags()
                end,
                desc = "Find: Help",
            },
            {
                "<leader>fe",
                function()
                    require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") })
                end,
                desc = "Find: Files From Buffer Directory",
            },
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.fzf")
        end,
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar", "GrugFarWithin" },
        keys = {
            {
                "<leader>fr",
                function()
                    require("grug-far").open()
                end,
                desc = "Find: Search and Replace",
            },
            {
                "<leader>fr",
                function()
                    require("grug-far").open({
                        visualSelectionUsage = "auto-detect",
                    })
                end,
                mode = "x",
                desc = "Find: Replace Selection",
            },
        },
        opts = {
            headerMaxWidth = 80,
        },
    },
}
