require("tiny-code-action").setup({
    -- Uses the existing FzfLua UI and avoids external diff tools on Windows.
    backend = "vim",
    picker = "fzf-lua",
    notify = {
        enabled = false,
    },
})
