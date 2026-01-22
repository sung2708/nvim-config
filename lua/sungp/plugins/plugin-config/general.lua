local M = require("sungp.helper.utils")
 return {
    {
        "github/copilot.vim",
        event = "InsertEnter",
    },
    {
        "jiangmiao/auto-pairs",
        event = "InsertEnter",
    },
    {
        "tpope/vim-surround",
        event = "VeryLazy",
    },
    {
        "terryma/vim-multiple-cursors",
        event = "VeryLazy",
    },
    {
        "tpope/vim-commentary",
        event = "VeryLazy",
    },
    {
       {'nvim-mini/mini.animate', version = '*'}
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        event = "BufReadPre",
        config = function()
            local render_markdown = M.safe_require("render-markdown")
            if not render_markdown then
                return
            end

            render_markdown.setup({
                preview_engine = "markdown-it",
                markdown_it_plugins = { "markdown-it-toc-done-right", "markdown-it-footnote" },
            })
        end,
    },
}