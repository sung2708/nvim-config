local M = require("helper.utils")

M.on_plugin_load("nvim-ts-autotag", "nvim-ts-autotag", function(auto_tag)
    auto_tag.setup({
        opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = false,
        },
    })
end)
