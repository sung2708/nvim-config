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
        lazy = true,
        init = not vim.g.sungp_low_spec and defer_after_vimenter("dropbar.nvim", 240) or nil,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            {
                "<leader>ub",
                function()
                    require("integrations.dropbar").toggle()
                end,
                desc = "UI: Toggle Breadcrumbs",
            },
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
        -- Load after the first frame; its dashboard/UI is optional on a
        -- low-spec machine and key mappings still load it on demand.
        lazy = vim.g.sungp_low_spec,
        event = vim.g.sungp_low_spec and "VeryLazy" or nil,
        priority = vim.g.sungp_low_spec and nil or 1000,
        keys = {
            {
                "<leader>uz",
                function()
                    Snacks.zen({ toggles = { dim = false, git_signs = false, mini_diff_signs = false } })
                end,
                desc = "UI: Zen Mode",
            },
            {
                "<leader>uZ",
                function()
                    Snacks.zen.zoom()
                end,
                desc = "UI: Zoom Window",
            },
            {
                "<leader>u.",
                function()
                    Snacks.scratch({ ft = "markdown" })
                end,
                desc = "UI: Scratch Notes",
            },
            {
                "<leader>uS",
                function()
                    Snacks.scratch.select()
                end,
                desc = "UI: Select Scratch",
            },
            {
                "<leader>uw",
                function()
                    Snacks.toggle.option("wrap"):toggle()
                end,
                desc = "UI: Toggle Wrap (Window)",
            },
            {
                "<leader>ud",
                function()
                    Snacks.toggle.diagnostics():toggle()
                end,
                desc = "UI: Toggle Diagnostics",
            },
            {
                "<leader>uf",
                function()
                    vim.g.disable_autoformat = not vim.g.disable_autoformat
                    vim.notify("Autoformat globally: " .. (vim.g.disable_autoformat and "off" or "on"))
                end,
                desc = "UI: Toggle Autoformat (Global)",
            },
            {
                "<leader>uF",
                function()
                    vim.b.disable_autoformat = not vim.b.disable_autoformat
                    vim.notify(
                        "Autoformat for buffer: "
                            .. (vim.b.disable_autoformat and "off" or "on")
                            .. (vim.g.disable_autoformat and " (globally disabled)" or "")
                    )
                end,
                desc = "UI: Toggle Autoformat (Buffer)",
            },
            {
                "<leader>uP",
                function()
                    Snacks.profiler.toggle()
                end,
                desc = "UI: Toggle Lua Profiler",
            },
            { "<leader>up", "<cmd>Lazy profile<cr>", desc = "UI: Plugin Load Profile" },
        },
        config = function()
            require("integrations.snacks")
        end,
    },
    {
        "LunarVim/bigfile.nvim",
        event = "BufReadPre",
        opts = {
            -- Keep the existing 1 MiB policy, but handle it before expensive
            -- filetype/LSP/Treesitter work starts.
            filesize = 1,
            features = {
                "indent_blankline",
                "illuminate",
                "lsp",
                "treesitter",
                "syntax",
                "matchparen",
                "vimopts",
                "filetype",
                {
                    name = "sungp_bigfile_marker",
                    disable = function(buf)
                        vim.b[buf].bigfile = true
                        vim.b[buf].completion = false
                        vim.b[buf].minianimate_disable = true
                        vim.b[buf].minihipatterns_disable = true
                        vim.opt_local.conceallevel = 0
                        vim.opt_local.relativenumber = false
                        vim.opt_local.statuscolumn = ""
                    end,
                },
            },
        },
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
        init = not vim.g.sungp_low_spec and defer_after_vimenter("hlchunk.nvim", 360) or nil,
        keys = {
            {
                "<leader>ui",
                function()
                    local group = "hlchunk_indent"
                    local ok, events = pcall(vim.api.nvim_get_autocmds, { group = group })
                    local enabled = ok and #events > 0
                    vim.cmd(enabled and "DisableHLIndent" or "EnableHLIndent")
                end,
                desc = "UI: Toggle Indent Guides",
            },
            {
                "<leader>uc",
                function()
                    local group = "hlchunk_chunk"
                    local ok, events = pcall(vim.api.nvim_get_autocmds, { group = group })
                    local enabled = ok and #events > 0
                    vim.cmd(enabled and "DisableHLChunk" or "EnableHLChunk")
                end,
                desc = "UI: Toggle Chunk Highlight",
            },
        },
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
