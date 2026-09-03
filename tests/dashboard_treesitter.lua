-- Empty-start dashboard must not synchronously start built-in Treesitter.
-- nvim --headless -u NONE -i NONE -l tests/dashboard_treesitter.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
assert(vim.fn.argc() == 0, 'run without file arguments')
local calls = {}
vim.treesitter.start = function(buf, lang)
    calls[#calls + 1] = { buf = buf, lang = lang }
end
require('config.autocmds')
local buf = vim.api.nvim_get_current_buf()
vim.bo[buf].filetype = 'lua'
local builtin = assert(loadstring('vim.treesitter.start(0, "lua")', '@/runtime/ftplugin/lua.lua'))
builtin()
assert(#calls == 0, 'dashboard open started Treesitter synchronously')
assert(vim.wait(1000, function() return #calls == 1 end), 'deferred highlighting never started')
assert(calls[1].buf == buf and calls[1].lang == 'lua')
vim.treesitter.start(buf, 'lua')
assert(#calls == 2, 'explicit Treesitter start must stay synchronous')
builtin()
vim.b[buf].bigfile = true
vim.wait(100)
assert(#calls == 2, 'big file should not start highlighting')
vim.b[buf].bigfile = nil
builtin()
vim.bo[buf].filetype = 'text'
vim.wait(100)
assert(#calls == 2, 'stale callback ran after filetype changed')
print('PASS dashboard Treesitter deferral, explicit calls, bigfile and stale-buffer guards')
vim.cmd.qa({ bang = true })
