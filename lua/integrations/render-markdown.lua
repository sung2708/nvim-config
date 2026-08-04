require("render-markdown").setup({
    latex = {
        enabled = vim.fn.executable("utftex") == 1 or vim.fn.executable("latex2text") == 1,
    },
})
