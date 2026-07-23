local M = require("helper.utils")

local function setup_noice()
    local noice = M.safe_require("noice")
    if not noice then
        return
    end

    noice.setup({
        cmdline = {
            enabled = true,
            view = "cmdline_popup",
            format = {
                cmdline = { pattern = "^:", icon = "", lang = "vim" },
                search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
                help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
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
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                filter_options = {},
            },
        },
    })
end

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("SungpNoiceLazy", { clear = true }),
    once = true,
    callback = function()
        vim.schedule(function()
            if M.load_plugins({ "noice.nvim" }) then
                setup_noice()
            end
        end)
    end,
})
