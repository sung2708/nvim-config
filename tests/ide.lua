-- Real installed servers/formatters; all source files live in a temporary project.
-- nvim --headless -u NONE -i NONE -l tests/ide.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
vim.o.loadplugins = true
local fixture = vim.fn.tempname() .. "-ide"
vim.fn.mkdir(fixture .. "/.git", "p")
vim.fn.writefile({ '{"compilerOptions":{"strict":true}}' }, fixture .. "/tsconfig.json")
vim.fn.writefile({ "module example.com/ide", "go 1.23" }, fixture .. "/go.mod")
vim.fn.writefile({ "[project]", 'name = "ide"', 'version = "0.1.0"' }, fixture .. "/pyproject.toml")
vim.fn.writefile({ "{}" }, fixture .. "/.luarc.json")
vim.env.XDG_STATE_HOME = fixture .. "/state"
package.preload["plugins.ai"] = function()
    return {}
end
require("config")
vim.o.swapfile = false
vim.o.hidden = true

local ok, err = xpcall(function()
    local cases = {
        { "main.py", "pyright", "value=1" },
        { "main.go", "gopls", "package main\nfunc main(){println(1)}" },
        { "main.ts", "ts_ls", "const value:number=1" },
        { "main.cpp", "clangd", "int main(){return 0;}" },
        { "main.lua", "lua_ls", "local value=1" },
        { "index.html", "html", "<html><body><p>hello</p></body></html>" },
        { "style.css", "cssls", "body{color:red}" },
        { "Main.java", "jdtls", "public class Main{public static void main(String[] args){System.out.println(1);}}" },
    }
    for _, case in ipairs(cases) do
        local path = fixture .. "/" .. case[1]
        vim.fn.writefile(vim.split(case[3], "\n"), path)
        vim.cmd.edit(vim.fn.fnameescape(path))
        local buf = vim.api.nvim_get_current_buf()
        assert(
            vim.wait(60000, function()
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, name = case[2] })) do
                    if client.initialized then
                        return true
                    end
                end
                return false
            end),
            case[2] .. " did not initialize for " .. case[1]
        )
        if case[1] == "main.py" then
            local plugins = require("lazy.core.config").plugins
            assert(
                not plugins["tiny-code-action.nvim"]._.loaded and not plugins["fzf-lua"]._.loaded,
                "LSP eagerly loaded a picker"
            )
            assert(vim.fn.maparg(" ca", "n", false, true).callback, "code-action mapping missing")
            assert(require("tiny-code-action").code_action, "on-demand code-action setup failed")
            assert(plugins["tiny-code-action.nvim"]._.loaded and plugins["fzf-lua"]._.loaded)
            io.stdout:write("PASS code-action picker stays lazy until first use\n")
        end
        if case[1] == "Main.java" then
            local client = vim.lsp.get_clients({ bufnr = buf, name = "jdtls" })[1]
            assert(
                not client:supports_method("textDocument/willSaveWaitUntil"),
                "Java still has a second blocking save owner"
            )
        end
        local before = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local format_error
        require("conform").format({ bufnr = buf, timeout_ms = 15000, lsp_format = "never" }, function(e)
            format_error = e
        end)
        assert(not format_error, tostring(format_error))
        assert(
            not vim.deep_equal(before, vim.api.nvim_buf_get_lines(buf, 0, -1, false)),
            case[1] .. " was not formatted"
        )
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, before)
        local started = vim.uv.hrtime()
        vim.cmd.write()
        local save_ms = (vim.uv.hrtime() - started) / 1e6
        if case[1] == "Main.java" then
            assert(
                vim.wait(15000, function()
                    local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                    return not vim.deep_equal(before, content) and vim.deep_equal(content, vim.fn.readfile(path))
                end),
                "Java format-after-save did not reach disk"
            )
        end
        local saved = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        assert(not vim.deep_equal(before, saved), case[1] .. " was not formatted on save: " .. vim.inspect({
            policy = require("helper.format").on_save(buf),
            formatters = require("conform").list_formatters(buf),
            log = require("conform.log").get_logfile(),
        }))
        assert(vim.deep_equal(saved, vim.fn.readfile(path)), case[1] .. " disk contents differ after save")
        io.stdout:write(
            ("PASS initialized LSP + external formatter + saved output: %s (save %.0f ms)\n"):format(case[1], save_ms)
        )
        io.stdout:flush()
    end
    local path = fixture .. "/bad.sh"
    vim.fn.writefile({ "#!/bin/sh", "echo $undefined" }, path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    local buf = vim.api.nvim_get_current_buf()
    require("lazy").load({ plugins = { "nvim-lint" } })
    vim.cmd.write()
    assert(
        vim.wait(10000, function()
            return #vim.diagnostic.get(buf, { namespace = require("lint").get_namespace("shellcheck") }) > 0
        end),
        "ShellCheck diagnostics missing after save"
    )
    io.stdout:write("PASS ShellCheck diagnostics on save\n")
end, debug.traceback)

local clients = vim.lsp.get_clients()
for _, client in ipairs(clients) do
    client:stop(true)
end
vim.wait(5000, function()
    return #vim.lsp.get_clients() == 0
end)
vim.cmd.enew({ bang = true })
if ok then
    vim.fn.delete(fixture, "rf")
else
    io.stderr:write("Fixture retained: " .. fixture .. "\n")
end
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd.cquit()
end
io.stdout:write("IDE integration checks passed\n")
vim.cmd.qa({ bang = true })
