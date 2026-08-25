return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            {
                "<leader>ff",
                function()
                    require("fzf-lua").files()
                end,
                desc = "Find: Files",
            },
            {
                "<leader>fg",
                function()
                    require("fzf-lua").live_grep()
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
