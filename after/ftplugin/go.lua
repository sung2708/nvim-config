vim.opt_local.expandtab = false
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 0
vim.opt_local.tabstop = 4

local function organize_imports(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
    end

    local has_gopls = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })) do
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeAction) then
            has_gopls = true
            break
        end
    end

    if not has_gopls then
        return
    end

    vim.lsp.buf.code_action({
        bufnr = bufnr,
        apply = true,
        context = {
            only = { "source.organizeImports" },
            diagnostics = vim.diagnostic.get(bufnr),
        },
    })
end

local organize_timer = vim.uv.new_timer()
local group = vim.api.nvim_create_augroup("SungpGoOrganizeImports" .. vim.api.nvim_get_current_buf(), {
    clear = true,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    buffer = 0,
    callback = function(args)
        if not vim.bo[args.buf].modified then
            return
        end

        organize_timer:stop()
        organize_timer:start(250, 0, function()
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == "go" then
                    organize_imports(args.buf)
                end
            end)
        end)
    end,
    desc = "Go: add missing imports and remove unused imports",
})

vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = 0,
    callback = function()
        if organize_timer and not organize_timer:is_closing() then
            organize_timer:stop()
            organize_timer:close()
        end
    end,
    desc = "Go: close organize imports timer",
})
