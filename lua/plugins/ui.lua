local defer_after_vimenter = require("helper.utils").defer_plugin_after_vimenter

return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            transparent_background = false,
            -- Avoid invoking vim.pack.get() on Neovim 0.12. This repository
            -- uses lazy.nvim exclusively, and the probe creates an empty
            -- site/pack/core tree that both health checks report as a conflict.
            auto_integrations = false,
        },
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        opts = {
            default = true,
        },
    },
    {
        "Bekaboo/dropbar.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            {
                "<leader>;",
                function()
                    require("dropbar.api").pick()
                end,
                desc = "Breadcrumb: Pick Symbol",
            },
            {
                "[;",
                function()
                    require("dropbar.api").goto_context_start()
                end,
                desc = "Breadcrumb: Context Start",
            },
            {
                "];",
                function()
                    require("dropbar.api").select_next_context()
                end,
                desc = "Breadcrumb: Next Context",
            },
        },
        config = function()
            require("integrations.dropbar")
        end,
    },
    {
        "folke/snacks.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("integrations.snacks")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.lualine")
        end,
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Buffer: Next" },
            { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer: Previous" },
            { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Buffer: Pin" },
            { "<leader>be", "<cmd>BufferLineMoveNext<cr>", desc = "Buffer: Move Right" },
            { "<leader>bq", "<cmd>BufferLineMovePrev<cr>", desc = "Buffer: Move Left" },
        },
        config = function()
            require("integrations.bufferline")
        end,
    },
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            require("integrations.notify")
        end,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("integrations.noice")
        end,
    },
    {
        "shellRaining/hlchunk.nvim",
        lazy = true,
        init = defer_after_vimenter("hlchunk.nvim", 360),
        config = function()
            require("integrations.hlchunk")
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("integrations.whichkey")
        end,
    },
}
