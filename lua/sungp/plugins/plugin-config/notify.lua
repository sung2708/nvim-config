local M = require("sungp.helper.utils")

return {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
        local notify = M.safe_require("notify")
        if not notify then
            return
        end

        notify.setup({
            render = "default",
            stages = "fade_in_slide_out",
            timeout = 3000,
            background_colour = "#000000",
        })

        vim.notify = notify
    end,
}