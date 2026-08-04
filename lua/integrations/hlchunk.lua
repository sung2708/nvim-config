local M = require("helper.utils")
local hlchunk = M.safe_require("hlchunk")

if hlchunk then
    local get_color = function()
        return "#00ffff"
    end
    local exclude_ft = {
        bigfile = true,
        ["neo-tree"] = true,
    }

    hlchunk.setup({
        chunk = {
            enable = true,
            use_treesitter = false,
            style = {
                { fg = get_color() },
                { fg = "#f35336" },
            },
            chars = {
                left_arrow = "─",
                horizontal_line = "─",
                vertical_line = "│",
                left_top = "╭",
                left_bottom = "╰",
                right_arrow = ">",
            },
            exclude_filetypes = exclude_ft,
            -- Avoid the plugin's async animation path, which can produce
            -- mismatched render state and crash on cursor moves.
            delay = 0,
            max_file_size = 1024 * 1024,
            priority = 15,
        },
        line_num = {
            enable = false,
            exclude_filetypes = exclude_ft,
            style = "#806d9c",
            priority = 10,
            use_treesitter = true,
        },
        indent = {
            enable = true,
            use_treesitter = false,
            style = {
                vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") or "#2f334d",
            },
            exclude_filetypes = exclude_ft,
            chars = { "│" },
            priority = 10,
            ahead_lines = 5,
            delay = 100,
        },
        blank = {
            enable = false,
            exclude_filetypes = exclude_ft,
            chars = {
                " ",
            },
            style = {
                { bg = "#434437" },
                { bg = "#2f4440" },
                { bg = "#433054" },
                { bg = "#284251" },
            },
        },
    })
end
