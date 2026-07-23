local function padded_border(padding)
    return {
        style = "rounded",
        padding = padding or { 1, 2 },
    }
end

require("noice").setup({
    cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
            input = { view = "cmdline_input", icon = "󰥻 " },
        },
    },
    lsp = {
        progress = { enabled = false },
        signature = { enabled = false },
        hover = { enabled = false },
        message = { enabled = true },
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            ["vim.lsp.util.stylize_markdown"] = false,
            ["cmp.entry.get_documentation"] = false,
        },
    },
    presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
    },
    messages = {
        enabled = true,
        view = "notify",
        view_search = "cmdline_popup",
    },
    popupmenu = {
        enabled = true,
        backend = "nui",
    },
    views = {
        cmdline_popup = {
            border = padded_border({ 0, 2 }),
            filter_options = {},
        },
        cmdline_popupmenu = {
            position = {
                row = 6,
                col = "50%",
            },
            border = padded_border(),
        },
        popupmenu = {
            border = padded_border(),
        },
        cmdline_input = {
            border = padded_border({ 0, 2 }),
        },
        confirm = {
            border = padded_border(),
        },
        popup = {
            border = padded_border(),
        },
        hover = {
            border = padded_border(),
        },
    },
})
