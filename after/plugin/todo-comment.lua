local M = require("helper.utils")
local todo = M.safe_require("todo-comments")
if todo then
todo.setup({ highlight = { keyword = "wide", after = "fg", pattern = [[.*<(KEYWORDS)\s*:]] } })
    vim.keymap.set("n", "]t", function() todo.jump_next() end)
    vim.keymap.set("n", "[t", function() todo.jump_prev() end)
end