return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        -- Do not parse the dashboard or the first file before it is visible.
        lazy = vim.g.sungp_low_spec,
        event = vim.g.sungp_low_spec and { "BufReadPost", "BufNewFile" } or nil,
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
