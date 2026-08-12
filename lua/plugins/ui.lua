local active_theme = require("config.theme").name
local defer_after_vimenter = require("helper.utils").defer_plugin_after_vimenter

local function is_active_theme(name)
    return active_theme == name or vim.startswith(active_theme, name .. "-")
end

return {
    {
        "folke/tokyonight.nvim",
        lazy = not is_active_theme("tokyonight"),
        priority = 1000,
        opts = {
            style = "night",
            transparent = false,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
        end,
    },
    {
        "shaunsingh/nord.nvim",
        name = "nord",
        lazy = not is_active_theme("nord"),
        priority = 1000,
        init = function()
            local opts = require("config.theme").nord
            vim.g.nord_contrast = opts.contrast
            vim.g.nord_borders = opts.borders
            vim.g.nord_disable_background = opts.disable_background
            vim.g.nord_italic = opts.italic
            vim.g.nord_uniform_diff_background = opts.uniform_diff_background
            vim.g.nord_bold = opts.bold
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = not is_active_theme("catppuccin"),
        priority = 999,
        opts = {
            transparent_background = false,
            -- Avoid invoking vim.pack.get() on Neovim 0.12. This repository
            -- uses lazy.nvim exclusively, and the probe creates an empty
            -- site/pack/core tree that both health checks report as a conflict.
            auto_integrations = false,
        },
    },
    {
        "rebelot/kanagawa.nvim",
        name = "kanagawa",
        lazy = not is_active_theme("kanagawa"),
        priority = 999,
        opts = function()
            return require("config.theme").kanagawa
        end,
        config = function(_, opts)
            require("kanagawa").setup(opts)
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        opts = {
            default = true,
        },
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
