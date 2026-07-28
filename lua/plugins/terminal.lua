return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        cmd = { "ToggleTerm", "TermExec", "TermSelect", "ToggleTermSendCurrentLine" },
        keys = {
            { "<C-\\>", mode = { "n", "t" }, desc = "Terminal: Toggle" },
            { "<leader>py", desc = "Terminal: Python REPL" },
            { "<leader>gg", desc = "Terminal: Lazygit" },
            { "<leader>ld", desc = "Terminal: Lazydocker" },
            { "<leader>th", desc = "Terminal: Horizontal" },
            { "<leader>tv", desc = "Terminal: Vertical" },
            { "<leader>tf", desc = "Terminal: Float" },
            { "<space>s", mode = "v", desc = "Terminal: Send Selection" },
        },
        config = function()
            require("integrations.toggleterm")
        end,
    },
    {
        "stevearc/overseer.nvim",
        cmd = { "OverseerRun", "OverseerToggle" },
        keys = {
            { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Tasks: Run" },
            { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Tasks: Toggle List" },
        },
        opts = {
            task_list = {
                direction = "bottom",
                min_height = 10,
                max_height = 20,
                default_detail = 1,
            },
        },
    },
}
