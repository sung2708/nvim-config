local defer_after_vimenter = require("helper.utils").defer_plugin_after_vimenter

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = true,
        init = defer_after_vimenter("nvim-treesitter", 100),
        cmd = { "TSInstall", "TSUpdate", "TSUninstall" },
        build = ":TSUpdate",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                branch = "main",
            },
        },
        config = function()
            require("integrations.treesitter")
        end,
    },
}
