local M = require("sungp.helper.utils")
 return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
        local conform = M.safe_require("conform")
        if not conform then
            return
        end

        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "black" },
                go = { "gofmt", "goimports" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                ["*"] = { "trim_whitespace", "end_of_file_newline" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            }
        })
    end,
}