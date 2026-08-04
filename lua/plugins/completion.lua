local function cmdline_position()
    if vim.g.ui_cmdline_pos ~= nil then
        local position = vim.g.ui_cmdline_pos
        return { position[1], position[2] }
    end

    local height = vim.o.cmdheight == 0 and 1 or vim.o.cmdheight
    return { vim.o.lines - height, 0 }
end

local defer_after_vimenter = require("helper.utils").defer_plugin_after_vimenter

return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        -- ModeChanged runs after Neovim is actually in Insert mode. Loading on
        -- InsertEnter leaves get_mode() at "n", so blink misses its own first
        -- buffer-local keymap installation and only works on the second insert.
        event = { "ModeChanged *:i", "CmdlineEnter" },
        -- Warm up Blink's Rust matcher after the first frame. Its Windows
        -- version/checksum probes are asynchronous but can take a few hundred
        -- milliseconds, so doing this in the background makes first insert
        -- completion ready without putting Blink back on the open-file path.
        init = defer_after_vimenter("blink.cmp", 40),
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        opts = {
            keymap = {
                preset = "none",
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<C-y>"] = { "select_and_accept", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Tab>"] = {
                    function(cmp)
                        if cmp.is_visible() then
                            return cmp.select_and_accept()
                        end
                    end,
                    "snippet_forward",
                    "fallback",
                },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<CR>"] = { "fallback" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<C-l>"] = { "show_signature", "hide_signature", "fallback" },
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                trigger = {
                    prefetch_on_insert = true,
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 50,
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
                    auto_show_delay_ms = 0,
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
        config = function(_, opts)
            local cmp = require("blink.cmp")
            cmp.setup(opts)

            -- setup() finishes the Rust matcher probe asynchronously. Apply
            -- the resolved mappings now so the first Insert does not need to
            -- leave and re-enter while that probe is still running.
            local config = require("blink.cmp.config")
            local keymap = require("blink.cmp.keymap")
            local mappings = keymap.get_mappings(config.keymap, "default")

            local function apply_keymaps()
                if not config.enabled() then
                    return false
                end
                require("blink.cmp.keymap.apply").keymap_to_current_buffer(mappings)
                return true
            end

            apply_keymaps()
            vim.api.nvim_create_autocmd("InsertEnter", {
                group = vim.api.nvim_create_augroup("SungpBlinkKeymapBootstrap", { clear = true }),
                callback = apply_keymaps,
            })
        end,
        opts_extend = { "sources.default" },
    },
}
