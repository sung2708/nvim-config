local M = require("sungp.helper.utils")
return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        event = "VeryLazy",
        opts = {
            ui = { border = "rounded" },
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
        config = function()
            local mason_lspconfig = M.safe_require("mason-lspconfig")
            if not mason_lspconfig then
                return
            end

            mason_lspconfig.setup({
                ensure_installed = {
                    "clangd",
                    "html",
                    "jsonls",
                    "pyright",
                    "taplo",
                    "ts_ls",
                    "vimls",
                    "yamlls",
                    "lua_ls",
                },
            })
        end,
    }
}