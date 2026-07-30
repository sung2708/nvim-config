return {
    {
        "atiladefreitas/dooing",
        cmd = { "Dooing", "DooingLocal", "DooingDue" },
        keys = {
            { "<leader>td", "<cmd>Dooing<cr>", desc = "Todo: Global List" },
            { "<leader>tD", "<cmd>DooingLocal<cr>", desc = "Todo: Project List" },
            { "<leader>tN", "<cmd>DooingDue<cr>", desc = "Todo: Due Items" },
        },
        opts = {
            per_project = {
                enabled = true,
                default_filename = "dooing.json",
                auto_gitignore = false,
                on_missing = "prompt",
                auto_open_project_todos = false,
            },
            due_notifications = {
                enabled = true,
                on_startup = false,
                on_open = true,
            },
        },
    },
}
