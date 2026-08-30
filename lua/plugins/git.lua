local defer_after_vimenter = require("helper.utils").defer_plugin_after_vimenter

return {
    {
        "lewis6991/gitsigns.nvim",
        lazy = true,
        init = defer_after_vimenter("gitsigns.nvim", 180),
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
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        keys = {
            { "<leader>gg", "<cmd>Neogit<cr>", desc = "Git: Neogit" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "ibhagwan/fzf-lua",
        },
        config = function()
            require("integrations.neogit")
        end,
    },
}
