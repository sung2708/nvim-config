local config_dir = vim.fn.stdpath("config")

local function first_executable(commands)
    for _, command in ipairs(commands) do
        if vim.fn.executable(command) == 1 then
            return command
        end
    end
end

if vim.fn.has("win32") == 1 then
    local zig_cc = config_dir .. "/bin/zig-cc.cmd"
    local zig_cxx = config_dir .. "/bin/zig-cxx.cmd"

    if not vim.env.CC and vim.fn.executable(zig_cc) == 1 then
        vim.env.CC = zig_cc
    end
    if not vim.env.CXX and vim.fn.executable(zig_cxx) == 1 then
        vim.env.CXX = zig_cxx
    end
else
    vim.env.CC = vim.env.CC or first_executable({ "cc", "clang", "gcc" })
    vim.env.CXX = vim.env.CXX or first_executable({ "c++", "clang++", "g++" })
end
