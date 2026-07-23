local function cmdline_position()
    if vim.g.ui_cmdline_pos ~= nil then
        local position = vim.g.ui_cmdline_pos
        return { position[1], position[2] }
    end

    local height = vim.o.cmdheight == 0 and 1 or vim.o.cmdheight
    return { vim.o.lines - height, 0 }
end

return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        opts = {
            keymap = {
                preset = "none",
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<C-l>"] = { "show_signature", "hide_signature", "fallback" },
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 250,
                    window = {
                        border = "rounded",
                    },
                },
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = false,
                    },
                },
                menu = {
                    border = "rounded",
                    cmdline_position = cmdline_position,
                    draw = {
                        padding = { 2, 2 },
                        gap = 1,
                        treesitter = { "lsp" },
                    },
                },
            },
            signature = {
                enabled = true,
                window = {
                    border = "rounded",
                },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            snippets = {
                preset = "default",
            },
            cmdline = {
                enabled = true,
                keymap = {
                    preset = "cmdline",
                },
                sources = { "buffer", "cmdline" },
                completion = {
                    menu = {
                        auto_show = function()
                            return vim.fn.getcmdtype() == ":"
                        end,
                    },
                    ghost_text = {
                        enabled = true,
                    },
                },
            },
        },
        opts_extend = { "sources.default" },
    },
}
