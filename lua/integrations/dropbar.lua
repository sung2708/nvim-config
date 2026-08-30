local excluded_filetypes = {
    "DressingInput",
    "NvimTree",
    "TelescopePrompt",
    "alpha",
    "dashboard",
    "fzf",
    "lazy",
    "mason",
    "neo-tree",
    "noice",
    "oil",
    "qf",
    "snacks_dashboard",
    "snacks_picker_input",
    "trouble",
}

local function is_enabled(bufnr, winid)
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(winid) then
        return false
    end

    -- Leave plugin-owned windows alone. This keeps the dashboard, explorers,
    -- pickers, terminals, help and quickfix windows visually focused.
    if vim.fn.win_gettype(winid) ~= "" or vim.wo[winid].winbar ~= "" or vim.bo[bufnr].buftype ~= "" then
        return false
    end

    if vim.tbl_contains(excluded_filetypes, vim.bo[bufnr].filetype) then
        return false
    end

    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return false
    end

    local stat = vim.uv.fs_stat(filename)
    return not stat or stat.size <= 1024 * 1024
end

require("dropbar").setup({
    bar = {
        enable = is_enabled,
        padding = {
            left = 1,
            right = 1,
        },
        -- Avoid redrawing repeatedly while moving quickly through large files.
        update_debounce = 80,
    },
    menu = {
        win_configs = {
            border = "rounded",
        },
    },
})
