return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("integrations.gitsigns")
        end,
    },
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gwrite", "Gread", "Ggrep", "Gclog" },
        keys = {
            { "<leader>gs", "<cmd>Git<cr>", desc = "Git: Status" },
            { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git: Commit" },
            { "<leader>gp", "<cmd>Git push<cr>", desc = "Git: Push" },
            { "<leader>gl", "<cmd>Git pull<cr>", desc = "Git: Pull" },
        },
    },
    {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewFileHistory",
            "DiffviewFocusFiles",
            "DiffviewToggleFiles",
            "DiffviewRefresh",
        },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git: Diff View" },
            { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Git: Close Diff View" },
            { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Git: File History" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
    },
}
