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
        "ray-x/go.nvim",
        ft = { "go", "gomod", "gowork", "gotmpl" },
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            { "<leader>Gi", "<cmd>GoIfErr<cr>", desc = "Go: Add If Error" },
            { "<leader>Gt", "<cmd>GoAddTag json<cr>", desc = "Go: Add JSON Tags" },
            { "<leader>GT", "<cmd>GoRmTag json<cr>", desc = "Go: Remove JSON Tags" },
            { "<leader>Gc", "<cmd>GoCmt<cr>", desc = "Go: Generate Comment" },
            { "<leader>Gf", "<cmd>GoAddTest<cr>", desc = "Go: Generate Function Test" },
            { "<leader>GF", "<cmd>GoAddAllTest<cr>", desc = "Go: Generate File Tests" },
            { "<leader>Ga", "<cmd>GoAlt<cr>", desc = "Go: Alternate Test File" },
            { "<leader>Gs", "<cmd>GoFillStruct<cr>", desc = "Go: Fill Struct" },
            { "<leader>GI", "<cmd>GoImpl<cr>", desc = "Go: Implement Interface" },
        },
        opts = {
            lsp_cfg = false,
            lsp_document_formatting = false,
            goimports = "gopls",
            gofmt = "gofumpt",
            tag_options = "json=omitempty",
            verbose = false,
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
