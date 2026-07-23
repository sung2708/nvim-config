local M = {}

M.safe_require = function(mod)
    local ok, m = pcall(require, mod)
    if not ok then
        vim.schedule(function()
            vim.notify("Failed to load " .. mod, vim.log.levels.WARN)
        end)
        return nil
    end
    return m
end

local function plugin_is_loaded(plugin)
    local spec = vim.g.plugs and vim.g.plugs[plugin]
    if not spec or not spec.dir then
        return true
    end

    local plugin_dir = vim.fs.normalize(spec.dir)
    if vim.fn.has("win32") == 1 then
        plugin_dir = plugin_dir:lower()
    end

    for _, runtime_dir in ipairs(vim.opt.runtimepath:get()) do
        local normalized = vim.fs.normalize(runtime_dir)
        if vim.fn.has("win32") == 1 then
            normalized = normalized:lower()
        end
        if normalized == plugin_dir then
            return true
        end
    end

    return false
end

M.on_plugin_load = function(plugin, mod, setup)
    if plugin_is_loaded(plugin) then
        local ok, loaded = pcall(require, mod)
        if ok then
            setup(loaded)
        else
            vim.notify("Failed to load " .. mod, vim.log.levels.WARN)
        end
        return
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = plugin,
        once = true,
        callback = function()
            local loaded_ok, lazy_loaded = pcall(require, mod)
            if not loaded_ok then
                vim.notify("Failed to load " .. mod, vim.log.levels.WARN)
                return
            end
            setup(lazy_loaded)
        end,
    })
end

M.load_plugins = function(plugins)
    if not vim.fn.exists("*plug#load") then
        return false
    end

    local unpack_fn = table.unpack or unpack
    local ok, err = pcall(vim.fn["plug#load"], unpack_fn(plugins))
    if not ok then
        vim.notify("Failed to load plugins: " .. tostring(err), vim.log.levels.ERROR)
    end
    return ok
end

return M
