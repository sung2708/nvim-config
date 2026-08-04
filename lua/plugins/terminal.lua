return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        cmd = { "ToggleTerm", "TermExec", "TermSelect", "ToggleTermSendCurrentLine" },
        keys = function()
            local keys = {
                { "<C-\\>", mode = { "n", "t" }, desc = "Terminal: Toggle" },
                { "<leader>py", desc = "Terminal: Python REPL" },
                -- Disabled temporarily: Windows terminal/ConPTY issue with LazyGit.
                -- { "<leader>gg", desc = "Terminal: Lazygit" },
                { "<leader>th", desc = "Terminal: Horizontal" },
                { "<leader>tv", desc = "Terminal: Vertical" },
                { "<leader>tf", desc = "Terminal: Float" },
                { "<space>s", mode = "v", desc = "Terminal: Send Selection" },
            }
            if vim.fn.executable("lazydocker") == 1 then
                table.insert(keys, { "<leader>ld", desc = "Terminal: Lazydocker" })
            end
            return keys
        end,
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
            dap = false,
            task_list = {
                direction = "bottom",
                min_height = 10,
                max_height = 20,
                default_detail = 1,
            },
        },
    },
}
