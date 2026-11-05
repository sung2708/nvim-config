-- Real Conform save pipeline with a slow, isolated formatter process.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/conform.nvim")
vim.o.swapfile = false
vim.o.hidden = true
require("config.options")
vim.o.swapfile = false
vim.o.undofile = false
local fixture = vim.fn.tempname() .. "-format"
vim.fn.mkdir(fixture, "p")
local script = fixture .. "/slow.lua"
vim.fn.writefile(
    { 'local text=io.read("*a")', "vim.wait(200)", "io.stdout:write(text:upper())", "io.stdout:flush()" },
    script
)
local opts, manual
for _, spec in ipairs(require("plugins.lsp")) do
    if spec[1] == "stevearc/conform.nvim" then
        opts = spec.opts
        manual = spec.keys[1][2]
    end
end
opts.formatters_by_ft.java = { "fixture_slow" }
opts.formatters.fixture_slow =
    { command = vim.v.progpath, args = { "--headless", "-u", "NONE", "-i", "NONE", "-l", script }, stdin = true }
local after_save, finished = opts.format_after_save, false
opts.format_after_save = function(buf)
    return after_save(buf), function()
        finished = true
    end
end
require("conform").setup(opts)
local path = fixture .. "/sample.java"
vim.cmd.edit(path)
vim.bo.filetype = "java"
local ok, err = xpcall(function()
    assert(opts.format_on_save(0) == nil, "Java still blocks save")
    assert(after_save(0), "Java formatter was disabled")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first source" })
    vim.cmd.write()
    assert(not finished, "formatting ran synchronously")
    assert(
        vim.wait(5000, function()
            return finished
        end),
        "formatter did not finish"
    )
    assert(vim.fn.readfile(path)[1] == "FIRST SOURCE" and vim.api.nvim_get_current_line() == "FIRST SOURCE")
    finished = false
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "second source" })
    vim.cmd.write()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "newer unsaved edit" })
    assert(
        vim.wait(5000, function()
            return finished
        end),
        "changed-buffer formatter did not finish"
    )
    assert(vim.api.nvim_get_current_line() == "newer unsaved edit" and vim.bo.modified, "async formatting lost edits")
    assert(vim.fn.readfile(path)[1] == "second source", "stale formatter rewrote the saved file")
    vim.cmd.enew({ bang = true })
    vim.api.nvim_buf_set_name(0, fixture .. "/large.lua")
    vim.bo.filetype = "lua"
    local lines = {}
    for i = 1, 10001 do
        lines[i] = "value=1"
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    require("config.autocmds")
    vim.api.nvim_exec_autocmds("BufReadPost", { buffer = 0 })
    assert(vim.bo.filetype == "bigfile" and vim.b.sungp_bigfile_filetype == "lua")
    assert(opts.format_on_save(0) == nil, "large-file autoformat should remain disabled")
    manual()
    assert(
        vim.wait(10000, function()
            return vim.api.nvim_get_current_line() == "value = 1"
        end),
        "manual bigfile formatting lost its language"
    )
end, debug.traceback)
vim.cmd.enew({ bang = true })
vim.fn.delete(fixture, "rf")
assert(ok, err)
print("PASS Java formatting runs after save, reaches disk and preserves newer unsaved edits")
print("PASS manual formatting keeps the original big-file language without enabling autoformat")
