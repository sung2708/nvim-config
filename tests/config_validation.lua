vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/blink.cmp")
local opts = require("plugins.completion")[1].opts
require("blink.cmp.config").merge_with(opts)
print("PASS installed Blink config validation")
for _, path in ipairs(vim.fn.glob("lua/**/*.lua", false, true)) do
    assert(loadfile(path), path)
end
print("PASS Lua syntax")

local fixture = vim.fn.tempname() .. "-toolchain"
vim.fn.mkdir(fixture .. "/first", "p")
vim.fn.mkdir(fixture .. "/second", "p")
local original_path = vim.env.PATH
vim.g.sungp_toolchain_paths = { fixture .. "/first", fixture .. "/second" }
for _ = 1, 2 do
    package.loaded["config.options"] = nil
    require("config.options")
end
local path = vim.split(vim.env.PATH, package.config:sub(1, 1) == "\\" and ";" or ":", { plain = true })
local offset = vim.fn.isdirectory(vim.fn.stdpath("data") .. "/mason/bin") == 1 and 1 or 0
assert(path[1 + offset] == fixture .. "/first" and path[2 + offset] == fixture .. "/second")
local count = 0
for _, entry in ipairs(path) do
    if entry == fixture .. "/first" then
        count = count + 1
    end
end
assert(count == 1, "toolchain PATH was duplicated")
vim.env.PATH, vim.g.sungp_toolchain_paths = original_path, nil
vim.fn.delete(fixture, "rf")
print("PASS managed toolchain PATH order and idempotency")

-- Windows PATH spelling must not accumulate duplicate slash/case variants.
local has, directory = vim.fn.has, vim.fn.isdirectory
local previous_path, previous_paths = vim.env.PATH, vim.g.sungp_toolchain_paths
vim.fn.has = function(feature)
    if feature == "win32" then
        return 1
    end
    if feature == "mac" then
        return 0
    end
    return has(feature)
end
vim.fn.isdirectory = function(value)
    if value == [[C:\Tools]] then
        return 1
    end
    return directory(value)
end
vim.g.sungp_toolchain_paths = { [[C:\Tools]] }
vim.env.PATH = [[C:\Tools;C:/tools;X:\bin]]
package.loaded["config.options"] = nil
require("config.options")
local variants = 0
for _, entry in ipairs(vim.split(vim.env.PATH, ";", { plain = true })) do
    if entry:gsub("\\", "/"):lower() == "c:/tools" then
        variants = variants + 1
    end
end
assert(variants == 1, "Windows PATH contains equivalent directories twice")
local java_home, scoop = vim.env.JAVA_HOME, vim.env.SCOOP
vim.env.SCOOP = [[C:\ScoopFixture]]
vim.env.JAVA_HOME = [[D:\Personal JDK]]
vim.g.sungp_toolchain_paths = {}
vim.fn.isdirectory = function(value)
    if value == [[D:\Personal JDK/bin]] or value:find("/apps/temurin", 1, true) then
        return 1
    end
    return directory(value)
end
package.loaded["config.options"] = nil
require("config.options")
assert(vim.env.PATH:find([[D:\Personal JDK/bin]], 1, true), "JAVA_HOME was not honored in PATH")
assert(not vim.env.PATH:find("temurin21-jdk", 1, true), "old Scoop JDK displaced the chosen JDK")
vim.env.JAVA_HOME = nil
package.loaded["config.options"] = nil
require("config.options")
assert(vim.env.JAVA_HOME == [[C:\ScoopFixture/apps/temurin25-jdk/current]], "Scoop did not prefer JDK 25")
vim.env.JAVA_HOME, vim.env.SCOOP = java_home, scoop
vim.fn.has, vim.fn.isdirectory = has, directory
vim.env.PATH, vim.g.sungp_toolchain_paths = previous_path, previous_paths
print("PASS Windows PATH normalizes slash and case variants")
