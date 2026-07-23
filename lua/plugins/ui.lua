return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            transparent = false,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme("tokyonight-night")
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        opts = {
            transparent_background = true,
        },
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },
    {
        "folke/snacks.nvim",
        lazy = false,
        priority = 900,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
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
        event = { "BufReadPost", "BufNewFile" },
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
