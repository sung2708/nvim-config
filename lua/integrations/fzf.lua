local fzf_lua = require("fzf-lua")

fzf_lua.setup({
    { "telescope", "hide" },
    winopts = {
        height = 0.78,
        width = 0.86,
        row = 0.5,
        col = 0.5,
        border = "rounded",
        backdrop = false,
        winblend = 0,
        preview = {
            border = "rounded",
            scrollbar = "border",
            winopts = {
                winblend = 0,
            },
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
        cmd = table.concat({
            'rg --files --hidden --glob "!.git/*"',
            '--glob "!node_modules/*"',
            '--glob "!dist/*"',
            '--glob "!build/*"',
            '--glob "!target/*"',
            '--glob "!.next/*"',
            '--glob "!coverage/*"',
        }, " "),
    },
    grep = {
        rg_opts = '--hidden --column --line-number --no-heading --color=always --smart-case --glob "!.git/*"',
    },
})
