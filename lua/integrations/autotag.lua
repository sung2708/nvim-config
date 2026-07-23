local auto_tag = require("nvim-ts-autotag")

auto_tag.setup({
    opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
    },
})
