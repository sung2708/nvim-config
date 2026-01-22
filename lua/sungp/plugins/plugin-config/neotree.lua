local M = require("sungp.helper.utils")

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<C-n>", "<cmd>Neotree filesystem reveal left<cr>", desc = "Neo-tree Reveal", silent = true },
        { "<C-t>", "<cmd>Neotree toggle<cr>", desc = "Neo-tree Toggle", silent = true },
        { "<C-f>", "<cmd>Neotree focus<cr>", desc = "Neo-tree Focus", silent = true },
    },
    config = function()
        local neotree = M.safe_require("neo-tree")
        if not neotree then
            return
        end

        neotree.setup({
            close_if_last_window = true,
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = true,
                },
            },
            window = {
                mappings = {
                    ["<space>"] = "none",
                },
            },
        })
    end,
}