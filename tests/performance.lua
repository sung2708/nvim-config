local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)
require("config.autocmds")
local function check(lines, expected)
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_exec_autocmds("BufReadPost", { buffer = buf })
    assert((vim.b[buf].bigfile == true) == expected)
    if expected then
        assert(vim.bo[buf].filetype == "bigfile")
        assert(vim.b[buf].completion == false)
    end
    vim.api.nvim_buf_delete(buf, { force = true })
end
check({ "local normal = true" }, false)
vim.g.sungp_bigfile_line_length = 3000
check({ string.rep("x", 2500) }, false)
vim.g.sungp_bigfile_line_length = nil
check({ string.rep("x", 2001) }, true)
-- Edits must use the same line-length rule as opening a file.
for _, event in ipairs({ "TextChanged", "TextChangedI" }) do
    local pasted = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(pasted)
    vim.bo.filetype = "javascript"
    vim.api.nvim_buf_set_lines(pasted, 0, -1, false, { string.rep("x", 2500) })
    vim.g.sungp_bigfile_line_length = 3000
    vim.api.nvim_exec_autocmds(event, { buffer = pasted })
    assert(not vim.b.bigfile, "custom long-line limit ignored")
    vim.g.sungp_bigfile_line_length = nil
    vim.api.nvim_buf_set_lines(pasted, 0, -1, false, { string.rep("x", 50000) })
    vim.api.nvim_exec_autocmds(event, { buffer = pasted })
    assert(vim.b.bigfile and vim.bo.filetype == "bigfile", "pasted long line bypassed protection")
    assert(vim.b.sungp_bigfile_filetype == "javascript")
    vim.api.nvim_buf_delete(pasted, { force = true })
end
print("PASS pasted long lines honor protection and custom limits")
local lines = {}
for i = 1, 10001 do
    lines[i] = "x"
end
check(lines, true)
local opts = require("plugins.completion")[1].opts
assert(opts.cmdline.sources)
local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(buf)
assert(opts.enabled())
vim.bo.buftype = "nofile"
assert(not opts.enabled())
assert(#opts.sources.providers.buffer.opts.get_bufnrs() == 0)
print("PASS large/minified buffers and completion isolation")

-- A picker-open FileType must not load LSP synchronously or revive a closed file.
local loaded = 0
local loading_buf
package.loaded["lazy.core.config"] = { plugins = { ["nvim-lspconfig"] = { _ = {} } } }
package.loaded.lazy = {
    load = function()
        loaded = loaded + 1
        loading_buf = vim.api.nvim_get_current_buf()
    end,
}
local spec = require("plugins.lsp")[1]
spec.init()
local stale = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(stale)
vim.bo[stale].filetype = "lua"
vim.api.nvim_exec_autocmds("FileType", { pattern = "lua", modeline = false })
vim.api.nvim_buf_delete(stale, { force = true })
-- Use a current real buffer so the callback captures the selected file.
local target = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(target)
vim.bo.filetype = "lua"
vim.api.nvim_exec_autocmds("FileType", { pattern = "lua", modeline = false })
assert(loaded == 0, "LSP blocked FileType")
local other = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(other)
assert(
    vim.wait(1000, function()
        return loaded > 0
    end),
    "deferred LSP did not load"
)
assert(loaded == 1, "duplicate deferred LSP load")
assert(loading_buf == target, "deferred plugin configured the wrong buffer")
assert(vim.api.nvim_get_current_buf() == other, "deferred setup stole focus")
print("PASS LSP loading occurs after FileType")

-- File-size protection must not remove the ability to undo or recover edits.
local path = vim.fn.tempname() .. "-large.txt"
local large_lines = {}
for i = 1, 6500 do
    large_lines[i] = string.rep("x", 200)
end
vim.fn.writefile(large_lines, path)
vim.o.swapfile = true
vim.o.undolevels = 1000
vim.cmd.edit(path)
local large_buf = vim.api.nvim_get_current_buf()
assert(vim.b.bigfile and vim.bo.filetype == "bigfile")
assert(vim.bo.swapfile and vim.bo.undolevels ~= -1, "large file lost recovery/undo")
vim.api.nvim_buf_set_lines(large_buf, 0, 1, false, { "changed" })
vim.cmd("silent undo")
assert(vim.api.nvim_buf_get_lines(large_buf, 0, 1, false)[1] == large_lines[1], "large-file undo failed")
vim.api.nvim_buf_delete(large_buf, { force = true })
vim.fn.delete(path)
print("PASS large files retain swap and working undo")

local growing = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(growing)
vim.bo.filetype = "lua"
vim.wo.cursorline = true
vim.api.nvim_exec_autocmds("InsertEnter", { buffer = growing })
vim.api.nvim_buf_set_lines(growing, 0, -1, false, large_lines)
local clients, detach = vim.lsp.get_clients, vim.lsp.buf_detach_client
local shared = {
    id = 777,
    attached_buffers = { [growing] = true, [other] = true },
    stop = function()
        error("stopped a shared client")
    end,
}
vim.lsp.get_clients = function()
    return { shared }
end
vim.lsp.buf_detach_client = function(buf)
    shared.attached_buffers[buf] = nil
end
vim.api.nvim_exec_autocmds("TextChangedI", { buffer = growing })
vim.lsp.get_clients, vim.lsp.buf_detach_client = clients, detach
assert(vim.b.bigfile and not shared.attached_buffers[growing] and shared.attached_buffers[other])
vim.api.nvim_exec_autocmds("InsertLeave", { buffer = growing })
assert(not vim.wo.cursorline and vim.bo.swapfile and vim.bo.undolevels ~= -1)
print("PASS growing files detach only their LSP buffer and keep rendering disabled after Insert")
