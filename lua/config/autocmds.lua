local core_group = vim.api.nvim_create_augroup("SungpCore", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group = core_group,
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
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
