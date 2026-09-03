local M = {}

function M.on_save(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
        return nil
    end
    if
        vim.bo[bufnr].buftype ~= ""
        or not vim.bo[bufnr].modifiable
        or vim.g.disable_autoformat
        or vim.b[bufnr].disable_autoformat
        or vim.b[bufnr].bigfile
        or vim.bo[bufnr].filetype == "bigfile"
    then
        return nil
    end

    -- Also catch files that grew after Snacks checked them on opening.
    local lines = vim.api.nvim_buf_line_count(bufnr)
    local bytes = vim.api.nvim_buf_get_offset(bufnr, lines)
    if bytes > 1024 * 1024 or bytes / math.max(lines, 1) > 500 then
        return nil
    end

    local timeout = vim.b[bufnr].autoformat_timeout_ms or vim.g.autoformat_timeout_ms
    if type(timeout) ~= "number" or timeout < 1 or timeout ~= timeout or timeout == math.huge then
        -- JVM cold starts need more time than the smaller native formatters.
        timeout = vim.bo[bufnr].filetype == "java" and 3000 or 1000
    end
    return { bufnr = bufnr, timeout_ms = math.floor(timeout), lsp_format = "fallback" }
end

return M
