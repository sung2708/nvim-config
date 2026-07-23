local M = require("helper.utils")
local todo = M.safe_require("todo-comments")
if todo then
todo.setup({
    signs = true,
    highlight = {
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
    },
    search = {
        command = "rg",
        args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
        },
        pattern = [[\b(KEYWORDS):]],
    },
})

    vim.keymap.set("n", "]t", function() todo.jump_next() end, { desc = "Todo: Next" })
    vim.keymap.set("n", "[t", function() todo.jump_prev() end, { desc = "Todo: Previous" })
    vim.keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo: Trouble" })
    vim.keymap.set("n", "<leader>xT", "<cmd>TodoTelescope<cr>", { desc = "Todo: Telescope" })
    vim.keymap.set("n", "<leader>xf", function()
        M.load_plugins({ "fzf-lua" })
        vim.cmd("TodoFzfLua")
    end, { desc = "Todo: FzfLua" })
    vim.keymap.set("n", "<leader>xq", "<cmd>TodoQuickFix<cr>", { desc = "Todo: Quickfix" })
    vim.keymap.set("n", "<leader>xl", "<cmd>TodoLocList<cr>", { desc = "Todo: Location List" })
    vim.keymap.set("n", "<leader>xF", function()
        M.load_plugins({ "fzf-lua" })
        vim.cmd("TodoFzfLua keywords=TODO,FIX,FIXME")
    end, { desc = "Todo/Fix: FzfLua" })
    vim.keymap.set("n", "<leader>xR", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", { desc = "Todo/Fix: Trouble" })
end
