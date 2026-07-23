local fzf_lua = require("fzf-lua")

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
        ["--padding"] = "1,2",
    },
    files = {
        cmd = 'rg --files --hidden --glob "!.git/*"',
    },
    grep = {
        rg_opts = '--hidden --column --line-number --no-heading --color=always --smart-case --glob "!.git/*"',
    },
})
