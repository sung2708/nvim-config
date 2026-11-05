-- Native buffer/highlight lifecycle with an in-memory LSP client.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.g.mapleader = " "
package.loaded["blink.cmp"] = {
    get_lsp_capabilities = function()
        return {}
    end,
}
package.loaded["mason-lspconfig"] = { setup = function() end }
local config, enable = vim.lsp.config, vim.lsp.enable
vim.lsp.config = setmetatable(
    { ts_ls = {
        root_dir = function(_, callback)
            callback(vim.fn.getcwd())
        end,
    } },
    { __call = function() end }
)
vim.lsp.enable = function() end
require("integrations.lsp")
vim.lsp.config, vim.lsp.enable = config, enable
local source = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(source)
vim.api.nvim_buf_set_lines(source, 0, -1, false, { "hello" })
local clients, get_client = vim.lsp.get_clients, vim.lsp.get_client_by_id
vim.lsp.get_client_by_id = function()
    return {
        name = "fixture",
        supports_method = function(_, method)
            return method == "textDocument/documentHighlight"
        end,
    }
end
vim.api.nvim_exec_autocmds("LspAttach", { buffer = source, data = { client_id = 1 } })
local ns = vim.api.nvim_create_namespace("nvim.lsp.references")
vim.api.nvim_buf_set_extmark(source, ns, 0, 0, { end_col = 3, hl_group = "Search" })
vim.lsp.get_clients = function()
    return {}
end
vim.api.nvim_exec_autocmds("LspDetach", { buffer = source, data = { client_id = 1 } })
local other = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(other)
assert(vim.wait(1000, function()
    return #vim.api.nvim_buf_get_extmarks(source, ns, 0, -1, {}) == 0
end))
assert(vim.api.nvim_get_current_buf() == other, "detach cleanup stole focus")
vim.lsp.get_clients, vim.lsp.get_client_by_id = clients, get_client
print("PASS last LSP detach clears stale highlights in its original buffer")
