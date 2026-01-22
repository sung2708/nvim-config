local M = require("sungp.helper.utils")

return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = "VeryLazy",
    keys = {
        { "<C-p>", "<cmd>BufferLineTogglePin<cr>", desc = "Buffer: Toggle Pin" },
        { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Buffer: Next" },
        { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer: Previous" },
        { "<leader>bc", "<cmd>bdelete<cr>", desc = "Buffer: Close" },
        { "<leader>be", "<cmd>BufferLineMoveNext<cr>", desc = "Buffer: Move Next" },
        { "<leader>bq", "<cmd>BufferLineMovePrev<cr>", desc = "Buffer: Move Previous" },
    },
    config = function()
        local bufferline = M.safe_require("bufferline")
        if not bufferline then return end

        bufferline.setup({
            options = {
                mode = "buffers",
                style_preset = {
                    bufferline.style_preset.no_italic,
                    bufferline.style_preset.no_bold
                },
                indicator = { icon = "▎", style = "icon" },
                buffer_close_icon = "󰅖",
                modified_icon = "●",
                close_icon = "",
                left_trunc_marker = "",
                right_trunc_marker = "",
                
                -- Diagnostics
                diagnostics = "nvim_lsp", 
                numbers = "ordinal",
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local s = " "
                    for n, c in pairs(diagnostics_dict) do
                        local sym = n == "error" and " "
                            or (n == "warning" and " " or " ")
                        s = s .. c .. sym
                    end
                    return vim.trim(s)
                end,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "File Explorer",
                        highlight = "Directory",
                        separator = true,
                        text_align = "center",
                    },
                },
                
                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = {'close'}
                },
                separator_style = "slope",
                always_show_bufferline = true,
                
                groups = {
                    items = {
                        require('bufferline.groups').builtin.pinned:with({ icon = "󰐃 " })
                    }
                }
            },
        })
    end,
}