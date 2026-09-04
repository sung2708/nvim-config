local defer_after_vimenter = require("helper.utils").defer_plugin_after_vimenter

return {
    {
        "folke/persistence.nvim",
        lazy = true,
        init = not vim.g.sungp_low_spec and defer_after_vimenter("persistence.nvim", 520) or nil,
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
