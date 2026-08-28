require("render-markdown").setup({
    file_types = { "markdown", "markdown.mdx", "codecompanion" },
    heading = {
        width = "block",
        left_pad = 1,
        right_pad = 1,
        sign = false,
    },
    code = {
        width = "block",
        left_pad = 1,
        right_pad = 1,
        border = "thin",
        sign = false,
    },
    dash = {
        width = 0.8,
        left_margin = 0.1,
    },
    pipe_table = {
        preset = "round",
        padding = 1,
    },
    sign = {
        enabled = false,
    },
    latex = {
        enabled = vim.fn.executable("utftex") == 1 or vim.fn.executable("latex2text") == 1,
    },
})
