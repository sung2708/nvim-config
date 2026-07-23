return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        event = { "BufReadPost", "BufNewFile" },
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
