local core_group = vim.api.nvim_create_augroup("SungpCore", { clear = true })

-- Reduce rendering work without sacrificing undo, swap or recovery.
local function mark_bigfile(buf)
    if vim.bo[buf].filetype ~= "bigfile" then
        vim.b[buf].sungp_bigfile_filetype = vim.bo[buf].filetype ~= "" and vim.bo[buf].filetype
            or vim.filetype.match({ filename = vim.api.nvim_buf_get_name(buf) })
    end
    vim.b[buf].bigfile = true
    vim.b[buf].completion = false
    vim.bo[buf].filetype = "bigfile"
    vim.bo[buf].syntax = "OFF"
    vim.diagnostic.enable(false, { bufnr = buf })
    pcall(vim.treesitter.stop, buf)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        vim.lsp.buf_detach_client(buf, client.id)
        if not next(client.attached_buffers) then
            client:stop()
        end
    end
    vim.api.nvim_buf_call(buf, function()
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.cursorcolumn = false
        vim.opt_local.cursorline = false
        vim.opt_local.relativenumber = false
        vim.opt_local.statuscolumn = ""
        vim.opt_local.conceallevel = 0
    end)
end

vim.api.nvim_create_autocmd("BufReadPre", {
    group = core_group,
    callback = function(args)
        local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
        if stat and stat.size > 1024 * 1024 then
            mark_bigfile(args.buf)
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged", "TextChangedI" }, {
    group = core_group,
    callback = function(args)
        local buf = args.buf
        if vim.bo[buf].buftype ~= "" or vim.b[buf].bigfile then
            return
        end
        local count = vim.api.nvim_buf_line_count(buf)
        local large = count > (vim.g.sungp_bigfile_lines or 10000)
            or vim.api.nvim_buf_get_offset(buf, count) > 1024 * 1024
        if not large then
            for first = 0, count - 1, 256 do
                for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, first, math.min(first + 256, count), false)) do
                    if #line > (vim.g.sungp_bigfile_line_length or 2000) then
                        large = true
                        break
                    end
                end
                if large then
                    break
                end
            end
        end
        if large then
            mark_bigfile(buf)
        end
    end,
})

-- Neovim's built-in ftplugins for these filetypes start Treesitter
-- synchronously inside FileType, which delays the first rendered frame. Defer
-- only those built-in calls, including files selected from an empty-start dashboard.
-- Explicit plugin/user calls keep normal semantics.
if not vim.g.sungp_deferred_builtin_treesitter then
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
        if not vim.b.bigfile and vim.w[win].sungp_restore_cursorcolumn then
            vim.wo[win].cursorcolumn = true
        end
        if not vim.b.bigfile and vim.w[win].sungp_restore_cursorline then
            vim.wo[win].cursorline = true
        end
        if not vim.b.bigfile and vim.w[win].sungp_restore_relativenumber then
            vim.wo[win].relativenumber = true
        end
        vim.w[win].sungp_restore_cursorcolumn = nil
        vim.w[win].sungp_restore_cursorline = nil
        vim.w[win].sungp_restore_relativenumber = nil
    end,
})
