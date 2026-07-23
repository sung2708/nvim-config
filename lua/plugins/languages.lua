return {
    {
        "linux-cultist/venv-selector.nvim",
        ft = "python",
        cmd = { "VenvSelect", "VenvSelectCache", "VenvSelectLog" },
        keys = {
            { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Python: Select Virtualenv" },
        },
        dependencies = {
            "ibhagwan/fzf-lua",
            "neovim/nvim-lspconfig",
        },
        opts = {
            options = {
                picker = "fzf-lua",
                notify_user_on_venv_activation = true,
            },
        },
    },
    {
        "olexsmir/gopher.nvim",
        ft = "go",
        keys = {
            { "<leader>Gi", "<cmd>GoIfErr<cr>", desc = "Go: Add If Error" },
            { "<leader>Gt", "<cmd>GoTagAdd json<cr>", desc = "Go: Add JSON Tags" },
            { "<leader>GT", "<cmd>GoTagRm json<cr>", desc = "Go: Remove JSON Tags" },
            { "<leader>Gc", "<cmd>GoCmt<cr>", desc = "Go: Generate Comment" },
            { "<leader>Gf", "<cmd>GoTestAdd<cr>", desc = "Go: Generate Function Test" },
            { "<leader>GF", "<cmd>GoTestsAll<cr>", desc = "Go: Generate File Tests" },
        },
        opts = {
            timeout = 4000,
        },
    },
    {
        "pmizio/typescript-tools.nvim",
        ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        keys = {
            { "<leader>Ti", "<cmd>TSToolsOrganizeImports<cr>", desc = "TypeScript: Organize Imports" },
            { "<leader>Ta", "<cmd>TSToolsAddMissingImports<cr>", desc = "TypeScript: Add Missing Imports" },
            { "<leader>Tu", "<cmd>TSToolsRemoveUnused<cr>", desc = "TypeScript: Remove Unused" },
            { "<leader>Tf", "<cmd>TSToolsFixAll<cr>", desc = "TypeScript: Fix All" },
            { "<leader>Tr", "<cmd>TSToolsRenameFile<cr>", desc = "TypeScript: Rename File" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            "saghen/blink.cmp",
        },
        config = function()
            require("integrations.typescript")
        end,
    },
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        dependencies = {
            "mfussenegger/nvim-dap",
            "mason-org/mason.nvim",
        },
        config = function()
            require("integrations.java").setup()
        end,
    },
}
