local utils = require("helper.utils")
local defer_after_vimenter = utils.defer_plugin_after_vimenter
local defer_on_filetype = utils.defer_plugin_on_filetype

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
        "stevearc/oil.nvim",
        cmd = "Oil",
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Files: Open Parent Directory" },
            { "<leader>fo", "<cmd>Oil --float<cr>", desc = "Find: Oil File Browser" },
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            default_file_explorer = false,
            delete_to_trash = true,
            float = {
                border = "rounded",
                max_width = 0.9,
                max_height = 0.9,
            },
            view_options = {
                show_hidden = true,
            },
        },
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
                mode = { "n", "o" },
                desc = "Flash: Treesitter",
            },
            {
                "<leader>mS",
                function()
                    require("flash").treesitter()
                end,
                mode = "x",
                desc = "Flash: Treesitter",
            },
        },
        config = function()
            require("integrations.flash")
        end,
    },
    {
        "sphamba/smear-cursor.nvim",
        lazy = true,
        init = defer_after_vimenter("smear-cursor.nvim", 800),
        opts = {
            smear_insert_mode = false,
            vertical_bar_cursor_insert_mode = true,
        },
    },
    {
        "folke/todo-comments.nvim",
        lazy = true,
        init = defer_after_vimenter("todo-comments.nvim", 420),
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
        "gbprod/yanky.nvim",
        keys = {
            { "<leader>fy", "<cmd>YankyRingHistory<cr>", mode = { "n", "x" }, desc = "Find: Yank History" },
            { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank: Text" },
            { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Yank: Put After" },
            { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Yank: Put Before" },
            { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Yank: Put After and Move" },
            { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Yank: Put Before and Move" },
            { "[y", "<Plug>(YankyPreviousEntry)", desc = "Yank: Previous History Entry" },
            { "]y", "<Plug>(YankyNextEntry)", desc = "Yank: Next History Entry" },
        },
        opts = {
            ring = {
                history_length = 100,
                storage = "shada",
            },
            highlight = {
                on_put = true,
                on_yank = true,
                timer = 300,
            },
            preserve_cursor_position = {
                enabled = true,
            },
        },
    },
    {
        "kevinhwang91/nvim-ufo",
        lazy = true,
        keys = {
            {
                "zR",
                function()
                    require("ufo").openAllFolds()
                end,
                desc = "Folds: Open All",
            },
            {
                "zM",
                function()
                    require("ufo").closeAllFolds()
                end,
                desc = "Folds: Close All",
            },
            {
                "zr",
                function()
                    require("ufo").openFoldsExceptKinds()
                end,
                desc = "Folds: Open Except Kinds",
            },
            {
                "zm",
                function()
                    require("ufo").closeFoldsWith()
                end,
                desc = "Folds: Close One Level",
            },
            {
                "zK",
                function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then
                        vim.lsp.buf.hover()
                    end
                end,
                desc = "Folds: Peek or Hover",
            },
        },
        dependencies = {
            "kevinhwang91/promise-async",
        },
        init = function()
            defer_after_vimenter("nvim-ufo", 280)()
            vim.opt.foldcolumn = "1"
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99
            vim.opt.foldenable = true
        end,
        opts = {
            provider_selector = function(bufnr, _, buftype)
                if
                    buftype ~= ""
                    or vim.b[bufnr].bigfile
                    or vim.api.nvim_buf_line_count(bufnr) > 10000
                then
                    return ""
                end
                return { "treesitter", "indent" }
            end,
        },
    },
    {
        "nvim-mini/mini.nvim",
        event = "VeryLazy",
        config = function()
            require("mini.ai").setup({
                n_lines = 100,
                mappings = {
                    -- Preserve Neovim 0.12's built-in `an`/`in` syntax-node
                    -- selections instead of shadowing them.
                    around_next = "aN",
                    inside_next = "iN",
                },
            })
            require("mini.splitjoin").setup()
            require("mini.move").setup({
                mappings = {
                    left = "<leader>mh",
                    right = "<leader>ml",
                    down = "<leader>mj",
                    up = "<leader>mk",
                    line_left = "<leader>mh",
                    line_right = "<leader>ml",
                    line_down = "<leader>mj",
                    line_up = "<leader>mk",
                },
            })
            require("mini.bracketed").setup({
                comment = { suffix = "" },
                diagnostic = { suffix = "" },
                treesitter = { suffix = "" },
                undo = { suffix = "" },
                yank = { suffix = "" },
            })
        end,
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
        lazy = true,
        init = defer_on_filetype("render-markdown.nvim", { "markdown", "markdown.mdx", "Avante" }, 30),
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.render-markdown")
        end,
    },
}
