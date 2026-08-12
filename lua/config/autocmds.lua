local core_group = vim.api.nvim_create_augroup("SungpCore", { clear = true })

-- Neovim's built-in ftplugins for these filetypes start Treesitter
-- synchronously inside FileType, which delays the first rendered frame. Defer
-- only those built-in calls; explicit plugin/user calls keep normal semantics.
if vim.fn.argc() > 0 and not vim.g.sungp_deferred_builtin_treesitter then
    vim.g.sungp_deferred_builtin_treesitter = true
    local treesitter_start = vim.treesitter.start
    local deferred_filetypes = { help = true, lua = true, markdown = true, query = true }

    vim.treesitter.start = function(bufnr, lang)
        local caller = debug.getinfo(2, "S")
        local source = caller and caller.source:gsub("\\", "/") or ""
        local builtin_ft = source:match("/runtime/ftplugin/([%w_]+)%.lua$")

        if not deferred_filetypes[builtin_ft] then
            return treesitter_start(bufnr, lang)
        end

        bufnr = bufnr and bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
        local filetype = vim.bo[bufnr].filetype
        vim.defer_fn(function()
            if
                vim.api.nvim_buf_is_valid(bufnr)
                and vim.api.nvim_buf_is_loaded(bufnr)
                and vim.fn.bufwinid(bufnr) ~= -1
                and vim.bo[bufnr].filetype == filetype
                and not vim.b[bufnr].bigfile
            then
                pcall(treesitter_start, bufnr, lang)
            end
        end, 35)
    end
end

vim.api.nvim_create_autocmd("FocusGained", {
    group = core_group,
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = core_group,
    callback = function(args)
        if
            vim.fn.getcmdwintype() == ""
            and vim.api.nvim_buf_is_valid(args.buf)
            and vim.bo[args.buf].buftype == ""
            and vim.api.nvim_buf_get_name(args.buf) ~= ""
        then
            vim.cmd(("checktime %d"):format(args.buf))
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = core_group,
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    group = core_group,
    callback = function()
        local win = vim.api.nvim_get_current_win()
        vim.w[win].sungp_restore_cursorcolumn = vim.wo[win].cursorcolumn
        vim.w[win].sungp_restore_cursorline = vim.wo[win].cursorline
        vim.w[win].sungp_restore_relativenumber = vim.wo[win].relativenumber
        vim.wo[win].cursorcolumn = false
        vim.wo[win].cursorline = false
        vim.wo[win].relativenumber = false
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = core_group,
    callback = function()
        local win = vim.api.nvim_get_current_win()
        if vim.w[win].sungp_restore_cursorcolumn then
            vim.wo[win].cursorcolumn = true
        end
        if vim.w[win].sungp_restore_cursorline then
            vim.wo[win].cursorline = true
        end
        if vim.w[win].sungp_restore_relativenumber then
            vim.wo[win].relativenumber = true
        end
        vim.w[win].sungp_restore_cursorcolumn = nil
        vim.w[win].sungp_restore_cursorline = nil
        vim.w[win].sungp_restore_relativenumber = nil
    end,
})
