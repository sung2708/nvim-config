local M = {}

local function executable(names)
    for _, name in ipairs(names) do
        local path = vim.fn.exepath(name)
        if path ~= "" then
            return name, path
        end
    end
end

local function check_tool(label, names, required, purpose)
    local name, path = executable(names)
    if path then
        vim.health.ok(string.format("%s: %s (%s)", label, name, path))
        return true
    end

    local message = string.format("%s not found (%s)", label, purpose)
    if required then
        vim.health.error(message)
    else
        vim.health.warn(message)
    end
    return false
end

local function version_at_least(major, minor)
    local version = vim.version()
    return version.major > major or (version.major == major and version.minor >= minor)
end

function M.check()
    vim.health.start("Portable Neovim configuration")

    local version = vim.version()
    if version_at_least(0, 12) then
        vim.health.ok(string.format("Neovim %d.%d.%d", version.major, version.minor, version.patch))
    else
        vim.health.error("Neovim 0.12 or newer is required")
    end

    local uname = vim.uv.os_uname()
    vim.health.info(string.format("Platform: %s %s", uname.sysname, uname.machine))
    vim.health.info("Config: " .. vim.fn.stdpath("config"))
    vim.health.info("Data: " .. vim.fn.stdpath("data"))
    vim.health.info("State: " .. vim.fn.stdpath("state"))

    for _, kind in ipairs({ "data", "state", "cache" }) do
        local path = vim.fn.stdpath(kind)
        if vim.fn.isdirectory(path) == 1 and vim.fn.filewritable(path) == 2 then
            vim.health.ok(kind .. " directory is writable: " .. path)
        else
            vim.health.error(kind .. " directory is missing or not writable: " .. path)
        end
    end

    vim.health.start("Required tools")
    check_tool("Git", { "git" }, true, "plugin installation")
    check_tool("ripgrep", { "rg" }, true, "file search and live grep")
    check_tool("fzf", { "fzf" }, true, "interactive pickers")

    vim.health.start("Optional and language-specific tools")
    check_tool("Tree-sitter CLI", { "tree-sitter" }, false, "parser installation")
    check_tool("C compiler", { "cc", "clang", "gcc", "zig", "cl" }, false, "Treesitter/native plugins")
    check_tool("Node.js", { "node" }, false, "JavaScript tooling and debugging")
    check_tool("Python", { "python3", "python" }, false, "Python provider, tests, and REPL")
    check_tool("Ruff", { "ruff" }, false, "Python LSP and formatting")
    check_tool("Go", { "go" }, false, "Go tooling")
    check_tool("Java", { "java" }, false, "Java tooling")

    if vim.fn.has("win32") == 1 or vim.fn.has("mac") == 1 then
        vim.health.ok("System clipboard support is provided by the platform")
    else
        check_tool("Clipboard", { "wl-copy", "xclip", "xsel" }, false, "system clipboard")
    end

    local local_config = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "config", "local.lua")
    if vim.uv.fs_stat(local_config) then
        if vim.g.config_local_loaded then
            vim.health.ok("Machine-local override loaded: " .. local_config)
        else
            vim.health.error("Machine-local override exists but failed to load: " .. local_config)
        end
    else
        vim.health.info("No machine-local override (optional)")
    end
end

return M
