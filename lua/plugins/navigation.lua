return {
    {
        "cbochs/grapple.nvim",
        keys = {
            {
                "<leader>fm",
                function()
                    require("grapple").toggle()
                end,
                desc = "Find: Toggle File Mark",
            },
            {
                "<leader>fM",
                function()
                    require("grapple").toggle_tags()
                end,
                desc = "Find: Marked Files",
            },
            {
                "<leader>f1",
                function()
                    require("grapple").select({ index = 1 })
                end,
                desc = "Find: Mark 1",
            },
            {
                "<leader>f2",
                function()
                    require("grapple").select({ index = 2 })
                end,
                desc = "Find: Mark 2",
            },
            {
                "<leader>f3",
                function()
                    require("grapple").select({ index = 3 })
                end,
                desc = "Find: Mark 3",
            },
            {
                "<leader>f4",
                function()
                    require("grapple").select({ index = 4 })
                end,
                desc = "Find: Mark 4",
            },
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.grapple")
        end,
    },
}
