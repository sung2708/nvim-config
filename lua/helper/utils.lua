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

return M
