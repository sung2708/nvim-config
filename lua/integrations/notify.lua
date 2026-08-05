local M = require("helper.utils")
local notify = M.safe_require("notify")
if notify then
    notify.setup({
        timeout = 2000,
        render = "wrapped-default",
        stages = "slide",
    })
    vim.notify = notify
end
