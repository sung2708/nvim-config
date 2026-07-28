return {
    {
        "olimorris/codecompanion.nvim",
        version = "^19.0.0",
        cmd = {
            "CodeCompanion",
            "CodeCompanionActions",
            "CodeCompanionChat",
            "CodeCompanionCmd",
        },
        keys = {
            {
                "<leader>ia",
                "<cmd>CodeCompanionActions<cr>",
                mode = { "n", "x" },
                desc = "AI: Actions",
            },
            {
                "<leader>ic",
                "<cmd>CodeCompanionChat Toggle<cr>",
                mode = { "n", "x" },
                desc = "AI: Toggle Chat",
            },
            {
                "<leader>ii",
                "<cmd>CodeCompanion<cr>",
                mode = { "n", "x" },
                desc = "AI: Inline Prompt",
            },
            {
                "<leader>id",
                "<cmd>CodeCompanionChat Add<cr>",
                mode = "x",
                desc = "AI: Add Selection to Chat",
            },
            {
                "<leader>ie",
                ":'<,'>CodeCompanion /explain<cr>",
                mode = "x",
                desc = "AI: Explain Selection",
            },
            {
                "<leader>if",
                ":'<,'>CodeCompanion /fix<cr>",
                mode = "x",
                desc = "AI: Fix Selection",
            },
            {
                "<leader>it",
                ":'<,'>CodeCompanion /tests<cr>",
                mode = "x",
                desc = "AI: Generate Tests",
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            adapters = {
                acp = {
                    codex = function()
                        return require("codecompanion.adapters").extend("codex", {
                            defaults = {
                                auth_method = "chat-gpt",
                            },
                        })
                    end,
                },
            },
            interactions = {
                chat = {
                    adapter = "codex",
                    opts = {
                        completion_provider = "blink",
                        context_management = {
                            enabled = true,
                        },
                    },
                },
                inline = {
                    adapter = "copilot",
                },
                cmd = {
                    adapter = "copilot",
                },
            },
            display = {
                action_palette = {
                    provider = "telescope",
                },
                chat = {
                    show_settings = false,
                    show_token_count = true,
                    start_in_insert_mode = false,
                    window = {
                        layout = "vertical",
                        full_height = true,
                        position = "right",
                        width = 0.42,
                        border = "rounded",
                        opts = {
                            breakindent = true,
                            linebreak = true,
                            wrap = true,
                        },
                    },
                },
            },
        },
    },
}
