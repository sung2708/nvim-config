local M = require("helper.utils")

M.on_plugin_load("render-markdown.nvim", "render-markdown", function(markdown)
    markdown.setup({})
end)

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("SungpRenderMarkdownLazy", { clear = true }),
    pattern = { "*.md", "*.markdown", "*.mdx" },
    callback = function()
        M.load_plugins({ "render-markdown.nvim" })
    end,
})
