local M = require("sungp.helper.utils")

return {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local lualine = M.safe_require("lualine")
        if not lualine then
            return
        end

        lualine.setup()
    end,
}