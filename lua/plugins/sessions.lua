return {
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        keys = {
            {
                "<leader>qs",
                function()
                    require("persistence").load()
                end,
                desc = "Session: Restore Current Directory",
            },
            {
                "<leader>qS",
                function()
                    require("persistence").select()
                end,
                desc = "Session: Select",
            },
            {
                "<leader>ql",
                function()
                    require("persistence").load({ last = true })
                end,
                desc = "Session: Restore Last",
            },
            {
                "<leader>qd",
                function()
                    require("persistence").stop()
                end,
                desc = "Session: Stop Saving",
            },
        },
        opts = {
            branch = true,
            need = 1,
        },
    },
}
