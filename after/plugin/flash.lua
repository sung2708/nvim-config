local M = require("helper.utils")

local flash = M.safe_require("flash")
if flash then
    flash.setup({
        highlight = { groups = { flash = "Flash" } }
    })
end

vim.keymap.set({"n", "x", "o"}, "s", function() flash.jump() end)
vim.keymap.set({"n", "x", "o"}, "S", function() flash.treesitter() end)