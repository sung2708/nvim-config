-- Installer orchestration only: no downloads, system packages or real config writes.
local root = vim.fn.getcwd()
local source = vim.fn.readfile(root .. "/bin/bootstrap.lua")
local fixture = vim.fn.tempname() .. "-bootstrap"
vim.fn.mkdir(fixture .. "/bin", "p")
vim.fn.mkdir(fixture .. "/lua/config", "p")
vim.fn.mkdir(fixture .. "/tools", "p")
vim.fn.mkdir(fixture .. "/plugin", "p")
vim.fn.writefile(source, fixture .. "/bin/bootstrap.lua")
vim.fn.writefile({ '{"sample":{"commit":"locked"}}' }, fixture .. "/lazy-lock.json")
vim.fn.writefile({ "provider" }, fixture .. "/tools/python")
vim.env.SUNGP_INSTALL_JAVA_HOME = fixture .. "/jdk"
vim.env.SUNGP_INSTALL_PATH = fixture .. "/tools"
vim.env.SUNGP_INSTALL_PYTHON = fixture .. "/tools/python"
vim.fn.writefile({ "#!/bin/sh", "exit 0" }, fixture .. "/tools/tree-sitter")
vim.fn.setfperm(fixture .. "/tools/tree-sitter", "rwxr-xr-x")
vim.env.PATH = fixture .. "/tools:" .. vim.env.PATH
local original_stdpath, original_system, original_cmd, original_stderr = vim.fn.stdpath, vim.system, vim.cmd, io.stderr
vim.fn.stdpath = function(kind)
    return kind == "config" and fixture or fixture .. "/data"
end
local errors = {}
io.stderr = {
    write = function(_, message)
        errors[#errors + 1] = message
    end,
}
vim.cmd = {
    qa = function() end,
    cquit = function()
        error("cquit")
    end,
}
local original_add = vim.treesitter.language.add
vim.treesitter.language.add = function()
    return true
end
package.loaded["config.compiler"] = {}
local bad_package, bad_parser, bad_checksum, bad_commit
local installs = 0
local states = {}
local packages = {}
local names = { "debugpy", "delve", "codelldb", "formatter", "language-server" }
for _, name in ipairs(names) do
    packages[name] = {
        is_installed = function()
            return states[name] == true
        end,
        get_installed_version = function()
            return "1.0"
        end,
        install = function(_, _, callback)
            installs = installs + 1
            vim.schedule(function()
                states[name] = name ~= bad_package
                callback(states[name])
            end)
        end,
    }
end
vim.system = function(command)
    return {
        wait = function()
            if command[1] == "tree-sitter" then
                return { code = 0, stdout = "tree-sitter 0.26.11" }
            end
            if command[1]:find("/bin/java", 1, true) then
                return { code = 0, stderr = 'openjdk version "25.0.1"' }
            end
            if command[1] == "git" then
                return { code = 0, stdout = bad_commit and "wrong" or "locked" }
            end
            assert(command[1] == "curl")
            vim.fn.writefile({ "download" }, command[#command])
            return { code = 0, stdout = "" }
        end,
    }
end
package.preload.config = function()
    assert(vim.o.loadplugins, "-u NONE left runtime plugins disabled")
    return {}
end
package.loaded["config.parsers"] = { "lua", "python" }
package.loaded.lazy = { install = function() end, restore = function() end, load = function() end }
package.loaded["lazy.core.config"] =
    { plugins = { sample = { dir = fixture .. "/plugin" }, ["mason-tool-installer.nvim"] = { virtual = true } } }
package.loaded["lazy.core.plugin"] = {
    values = function()
        return { ensure_installed = { "formatter" } }
    end,
}
package.loaded["mason-registry"] = {
    refresh = function(callback)
        callback(true)
    end,
    get_package = function(name)
        return assert(packages[name], name)
    end,
}
package.loaded["mason-lspconfig.settings"] = { current = { ensure_installed = { "test_ls" } } }
package.loaded["mason-lspconfig.mappings"] = {
    get_mason_map = function()
        return { lspconfig_to_package = { test_ls = "language-server" } }
    end,
}
package.loaded["nvim-treesitter"] = {
    setup = function() end,
    install = function()
        return {
            await = function(_, callback)
                callback(nil, not bad_parser)
            end,
        }
    end,
    get_installed = function()
        return { "lua", "python" }
    end,
}
package.loaded["nvim-treesitter"].update = package.loaded["nvim-treesitter"].install
package.loaded["neotest-java.default_config"] = {
    default_junit_jar_filepath = {
        to_string = function()
            return fixture .. "/junit.jar"
        end,
    },
    default_junit_jar_version = { version = "pinned", sha256 = "good" },
}
package.loaded["neotest-java.util.checksum"] = {
    sha256 = function()
        return bad_checksum and "bad" or "good"
    end,
}
local report = fixture .. "/data/nvim-config/install-report.json"
local function execute(expected)
    errors = {}
    vim.fn.delete(report)
    local ok = pcall(dofile, fixture .. "/bin/bootstrap.lua")
    assert(ok == expected, table.concat(errors, "\n"))
    assert((vim.fn.filereadable(report) == 1) == expected, "incorrect success receipt")
    assert(table.concat(vim.fn.readfile(fixture .. "/lazy-lock.json")):find('"locked"', 1, true), "lockfile changed")
end
arg[1] = "--plugins"
assert(pcall(dofile, fixture .. "/bin/bootstrap.lua"))
assert(installs == 0 and vim.fn.filereadable(report) == 0, "plugin phase ran runtime installers")
arg[1] = nil
execute(true)
assert(installs == #names)
assert(loadfile(fixture .. "/lua/config/toolchain.lua"), "generated Lua is invalid")
execute(true)
assert(installs == #names, "rerun reinstalled existing Mason packages")
bad_package, states.debugpy = "debugpy", false
execute(false)
assert(table.concat(errors):find("debugpy", 1, true))
bad_package = nil
execute(true)
bad_parser = true
execute(false)
bad_parser, bad_commit = false, true
execute(false)
bad_commit, bad_checksum = false, true
execute(false)
vim.fn.stdpath, vim.system, vim.cmd, io.stderr = original_stdpath, original_system, original_cmd, original_stderr
vim.treesitter.language.add = original_add
vim.fn.delete(fixture, "rf")
print("PASS installer setup, retry, generated Lua, lockfile preservation and package/parser/checksum/commit failures")
