local fzf_lua = require("fzf-lua")
local ignored_dirs = {
    ".git",
    ".jj",
    ".hg",
    ".svn",
    "node_modules",
    "dist",
    "build",
    "target",
    ".next",
    "coverage",
    ".venv",
    "venv",
    "vendor",
    "out",
    "obj",
    ".cache",
}

local fd_excludes = table.concat(vim.tbl_map(function(dir)
    return "--exclude " .. dir
end, ignored_dirs), " ")

local rg_excludes = table.concat(vim.tbl_map(function(dir)
    return '--glob "!' .. dir .. '/*"'
end, ignored_dirs), " ")

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
        -- Let fzf-lua prefer fd. It respects .gitignore and is faster for
        -- file listing; <A-h> still toggles hidden files when needed.
        hidden = false,
        fd_opts = "--color=never --type f --type l " .. fd_excludes,
        -- Keep an rg fallback for machines without fd.
        rg_opts = "--color=never --files " .. rg_excludes,
    },
    grep = {
        -- Avoid scanning hidden/generated/dependency trees by default.
        -- <A-h> can be used to include hidden files for the current picker.
        hidden = false,
        -- Keep `!` globs out of this command on Windows. fzf-lua escapes
        -- them in `fix_windows_cmd`, which can break the live query
        -- placeholder and turn the query into an rg path argument.
        -- rg already respects .gitignore, including common dependency dirs.
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
    },
})
