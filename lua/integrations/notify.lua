local M = require("helper.utils")
local notify = M.safe_require("notify")
if notify then
    notify.setup({
        background_colour = "#000000",
        timeout = 2000,
        render = "wrapped-default",
        stages = "fade_in_slide_out",
        on_open = function(win)
            vim.api.nvim_set_option_value("winblend", 12, { win = win })
        end,
    })
    vim.notify = notify
end
