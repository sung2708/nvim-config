-- Real Go test execution through the configured Neotest adapter.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.o.loadplugins = true
local fixture = vim.fn.tempname() .. "-neotest"
vim.fn.mkdir(fixture, "p")
vim.env.XDG_STATE_HOME = fixture .. "/state"
vim.env.GOTOOLCHAIN = "local"
vim.env.GOPROXY = "off"
package.preload["plugins.ai"] = function()
    return {}
end
require("config")
vim.o.swapfile = false
local ok, err = xpcall(function()
    vim.fn.writefile({ "module example.com/neotest", "go 1.23" }, fixture .. "/go.mod")
    local path = fixture .. "/sample_test.go"
    vim.fn.writefile({ "package sample", 'import "testing"', "func TestPass(t *testing.T) {}" }, path)
    vim.cmd.edit(path)
    require("lazy").load({ plugins = { "neotest" } })
    local neotest = require("neotest")
    local function has_status(name)
        for _, adapter in ipairs(neotest.state.adapter_ids()) do
            local counts = neotest.state.status_counts(adapter)
            if counts and counts[name] == 1 then
                return true
            end
        end
        return false
    end
    neotest.run.run(path)
    assert(
        vim.wait(60000, function()
            return has_status("passed")
        end, 100),
        "Neotest did not report the passing Go test"
    )
    io.stdout:write("PASS Neotest discovers and runs a real Go test\n")
    io.stdout:flush()
    vim.api.nvim_buf_set_lines(
        0,
        0,
        -1,
        false,
        { "package sample", 'import "testing"', 'func TestPass(t *testing.T) { t.Fatal("fixture failure") }' }
    )
    vim.cmd.write()
    neotest.run.run(path)
    assert(
        vim.wait(60000, function()
            return has_status("failed")
        end, 100),
        "Neotest missed the failing Go test"
    )
    io.stdout:write("PASS Neotest reports the failing Go test after an edit\n")
    io.stdout:flush()
end, debug.traceback)
for _, client in ipairs(vim.lsp.get_clients()) do
    client:stop(true)
end
vim.cmd.enew({ bang = true })
vim.fn.delete(fixture, "rf")
if not ok then
    io.stderr:write(tostring(err) .. "\n")
    vim.cmd.cquit(1)
end
vim.cmd.qa({ bang = true })
