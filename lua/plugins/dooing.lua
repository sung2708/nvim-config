return {
    {
        "atiladefreitas/dooing",
        cmd = { "Dooing", "DooingLocal", "DooingDue" },
        keys = {
            { "<leader>td", "<cmd>Dooing<cr>", desc = "Todos: Global" },
            { "<leader>tD", "<cmd>DooingLocal<cr>", desc = "Todos: Project" },
            { "<leader>tN", "<cmd>DooingDue<cr>", desc = "Todos: Due Items" },
        },
        opts = {
            save_path = vim.fs.joinpath(vim.fn.stdpath("data"), "dooing_todos.json"),
            pretty_print_json = false,
            timestamp = {
                enabled = true,
            },
            window = {
                width = 58,
                height = 20,
                border = "rounded",
                position = "center",
            },
            per_project = {
                enabled = true,
                default_filename = "dooing.json",
                auto_gitignore = "prompt",
                on_missing = "prompt",
                auto_open_project_todos = false,
            },
            due_notifications = {
                enabled = true,
                on_startup = true,
                on_open = true,
            },
            keymaps = {
                toggle_window = "<leader>td",
                open_project_todo = "<leader>tD",
                show_due_notification = "<leader>tN",
            },
        },
    },
}
