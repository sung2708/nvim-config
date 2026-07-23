local M = require("helper.utils")

M.on_plugin_load("fzf-lua", "fzf-lua", function(fzf_lua)
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
        files = {
            cmd = 'rg --files --hidden --glob "!.git/*"',
        },
        grep = {
            rg_opts = '--hidden --column --line-number --no-heading --color=always --smart-case --glob "!.git/*"',
        },
    })
end)
