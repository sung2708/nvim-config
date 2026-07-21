local M = require("helper.utils")
local notify = M.safe_require("notify")
if notify then
    notify.setup({
        background_colour = "#1e1e2e", 
        timeout = 2000,
        render = "default",
        stages = "fade_in_slide_out",
    })
    vim.notify = notify
end
