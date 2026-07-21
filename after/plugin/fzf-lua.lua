local M = require("helper.utils")
local fzf_lua = M.safe_require("fzf-lua")

if fzf_lua then
    fzf_lua.setup({
        winopts = {
            border = "rounded",
            preview = {
                border = "rounded",
                scrollbar = "float",
            },
        },
        keymap = {
            builtin = {
                ["<C-d>"] = "preview-page-down",
                ["<C-u>"] = "preview-page-up",
            },
            fzf = {
                ["ctrl-q"] = "select-all+accept",
            },
        },
        fzf_opts = {
            ["--layout"] = "reverse",
            ["--info"] = "inline",
        },
    })
end
