local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    local output = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Failed to install lazy.nvim:\n" .. output)
    end
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    defaults = {
        lazy = true,
        version = false,
    },
    install = {
        colorscheme = { "tokyonight", "habamax" },
    },
    checker = {
        enabled = false,
    },
    change_detection = {
        notify = false,
    },
    ui = {
        border = "rounded",
    },
    rocks = {
        enabled = false,
    },
    performance = {
        cache = {
            enabled = true,
        },
    },
})
