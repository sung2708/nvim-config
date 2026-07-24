return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        keys = {
            { "<C-n>", "<cmd>Neotree filesystem reveal left<cr>", desc = "Explorer: Reveal File" },
            { "<C-t>", "<cmd>Neotree toggle<cr>", desc = "Explorer: Toggle" },
            { "<C-f>", "<cmd>Neotree focus<cr>", desc = "Explorer: Focus" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.neotree")
        end,
    },
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: Workspace Diagnostics" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble: Buffer Diagnostics" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Trouble: Symbols" },
            { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: Location List" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: Quickfix List" },
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.trouble")
        end,
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        keys = {
            {
                "s",
                function()
                    require("flash").jump()
                end,
                mode = { "n", "x", "o" },
                desc = "Flash: Jump",
            },
            {
                "S",
                function()
                    require("flash").treesitter()
                end,
                mode = { "n", "x", "o" },
                desc = "Flash: Treesitter",
            },
        },
        config = function()
            require("integrations.flash")
        end,
    },
    {
        "sphamba/smear-cursor.nvim",
        lazy = false,
        opts = {
            cursor_color = "#7DCFFF",
            smear_insert_mode = true,
            vertical_bar_cursor_insert_mode = true,
        },
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TodoTrouble", "TodoTelescope", "TodoFzfLua", "TodoQuickFix", "TodoLocList" },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("integrations.todo")
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            check_ts = true,
            disable_filetype = { "TelescopePrompt", "snacks_picker_input" },
            fast_wrap = {},
        },
    },
    {
        "tpope/vim-commentary",
        event = "VeryLazy",
    },
    {
        "tpope/vim-surround",
        event = "VeryLazy",
    },
    {
        "terryma/vim-multiple-cursors",
        event = "VeryLazy",
        init = function()
            vim.g.multi_cursor_start_word_key = "<M-n>"
            vim.g.multi_cursor_select_all_word_key = "<M-a>"
            vim.g.multi_cursor_start_key = "g<M-n>"
            vim.g.multi_cursor_select_all_key = "g<M-a>"
            vim.g.multi_cursor_next_key = "<M-n>"
            vim.g.multi_cursor_prev_key = "<M-p>"
            vim.g.multi_cursor_skip_key = "<M-x>"
            vim.g.multi_cursor_quit_key = "<Esc>"
        end,
    },
    {
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "windwp/nvim-ts-autotag",
        ft = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "svelte", "astro", "php" },
        config = function()
            require("integrations.autotag")
        end,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "markdown.mdx" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.render-markdown")
        end,
    },
    {
        "github/copilot.vim",
        cmd = "Copilot",
        event = "InsertEnter",
        cond = function()
            return vim.g.copilot_enabled == true
        end,
        init = function()
            vim.g.copilot_no_tab_map = true
        end,
        keys = {
            {
                "<M-\\>",
                'copilot#Accept("\\<CR>")',
                mode = "i",
                expr = true,
                replace_keycodes = false,
                desc = "Copilot: Accept",
            },
        },
    },
}
