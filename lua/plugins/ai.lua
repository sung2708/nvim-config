return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false,
        build = vim.fn.has("win32") ~= 0
                and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            or "make",
        cmd = {
            "AvanteAsk",
            "AvanteBuild",
            "AvanteChat",
            "AvanteChatNew",
            "AvanteClear",
            "AvanteEdit",
            "AvanteFocus",
            "AvanteHistory",
            "AvanteRefresh",
            "AvanteStop",
            "AvanteSwitchProvider",
            "AvanteToggle",
        },
        keys = {
            {
                "<leader>ia",
                function()
                    require("avante.api").ask({ new_chat = true })
                end,
                mode = { "n", "x" },
                desc = "AI: Ask",
            },
            { "<leader>ic", "<cmd>AvanteChat<cr>", mode = { "n", "x" }, desc = "AI: Chat" },
            {
                "<leader>ii",
                function()
                    require("avante.api").ask({ new_chat = true })
                end,
                mode = { "n", "x" },
                desc = "AI: Ask",
            },
            { "<leader>in", "<cmd>AvanteChatNew<cr>", desc = "AI: New Chat" },
            { "<leader>ih", "<cmd>AvanteHistory<cr>", desc = "AI: History" },
            { "<leader>is", "<cmd>AvanteStop<cr>", desc = "AI: Stop" },
            { "<leader>iF", "<cmd>AvanteFocus<cr>", desc = "AI: Focus" },
            { "<leader>im", "<cmd>AvanteSwitchProvider<cr>", desc = "AI: Switch Provider" },
            {
                "<leader>ie",
                function()
                    require("avante.api").ask({ question = "Explain this selection", new_chat = true })
                end,
                mode = "x",
                desc = "AI: Explain Selection",
            },
            {
                "<leader>if",
                function()
                    require("avante.api").edit("Fix this selection")
                end,
                mode = "x",
                desc = "AI: Fix Selection",
            },
            {
                "<leader>ir",
                function()
                    require("avante.api").edit("Refactor this selection")
                end,
                mode = "x",
                desc = "AI: Refactor Selection",
            },
            {
                "<leader>it",
                function()
                    require("avante.api").ask({ question = "Generate tests for this selection", new_chat = true })
                end,
                mode = "x",
                desc = "AI: Generate Tests",
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "folke/snacks.nvim",
            "nvim-telescope/telescope.nvim",
            "ibhagwan/fzf-lua",
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true,
                    },
                },
            },
        },
        config = function(_, opts)
            require("avante").setup(opts)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "Avante",
                callback = function(event)
                    vim.keymap.set("n", "i", function()
                        local sidebar = require("avante").get()
                        if sidebar and sidebar.focus_input then
                            sidebar:focus_input()
                            vim.cmd("startinsert")
                        end
                    end, { buffer = event.buf, silent = true, desc = "Avante: Focus Input" })
                end,
            })
        end,
        opts = {
            provider = "codex",
            mode = "agentic",
            instructions_file = "avante.md",
            acp_providers = {
                codex = {
                    command = vim.fn.has("win32") ~= 0 and "cmd.exe" or "codex-acp",
                    args = vim.fn.has("win32") ~= 0 and { "/d", "/s", "/c", "codex-acp" } or {},
                    env = {
                        NODE_NO_WARNINGS = "1",
                    },
                },
            },
            input = {
                provider = "snacks",
                provider_opts = {
                    title = "Avante",
                    icon = " ",
                },
            },
            selector = {
                provider = "fzf_lua",
            },
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = true,
                minimize_diff = true,
                enable_token_counting = true,
                auto_add_current_file = true,
                auto_approve_tool_permissions = false,
                confirmation_ui_style = "inline_buttons",
                acp_follow_agent_locations = true,
            },
            windows = {
                position = "right",
                wrap = true,
                width = 42,
                sidebar_header = {
                    enabled = true,
                    align = "center",
                    rounded = true,
                    include_model = true,
                },
            },
        },
    },
}
