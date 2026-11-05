-- Installed parser/query integration; no downloads or source files are changed.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.g.mapleader = " "
for _, name in ipairs({ "nvim-treesitter", "nvim-treesitter-textobjects" }) do
    vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/" .. name)
end
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
require("integrations.treesitter")
vim.bo.filetype = "lua"
for _, case in ipairs({
    { "call(a, b, c)", 9, " mP", "call(b, a, c)" },
    { "call(a, b, c)", 12, " mP", "call(a, c, b)" },
    { "call(a, b)", 9, " mP", "call(b, a)" },
    { "call(a, b)", 6, " mp", "call(b, a)" },
}) do
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { case[1] })
    vim.treesitter.start(0, "lua")
    vim.treesitter.get_parser(0):parse()
    vim.api.nvim_win_set_cursor(0, { 1, case[2] - 1 })
    vim.fn.maparg(case[3], "n", false, true).callback()
    -- The plugin makes swaps dot-repeatable through an operator callback.
    _G._nvim_treesitter_textobject_last_function()
    assert(vim.api.nvim_get_current_line() == case[4], vim.api.nvim_get_current_line())
end
print("PASS parameter swaps work in both directions, including first/last arguments")
