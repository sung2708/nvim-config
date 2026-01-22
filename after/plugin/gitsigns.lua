local M = require("helper.utils")
local gitsigns = M.safe_require("gitsigns")

if gitsigns then
    gitsigns.setup({
        signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        
        signs_staged_enable = true,
        signcolumn          = true,
        numhl               = true,
        linehl              = false, 
        word_diff           = false,
        
        watch_gitdir = {
            follow_files = true
        },
        auto_attach         = true,
        attach_to_untracked = false,

        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol',
            delay = 500,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        
        sign_priority   = 6,
        update_debounce = 100,
        status_formatter = nil, 
        max_file_length = 40000, 
        
        preview_config = {
            border = 'rounded',
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
        },

        on_attach = function(bufnr)
            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal({']c', bang = true})
                else
                    gitsigns.nav_hunk('next')
                end
            end, { desc = "Git: Next Hunk" })

            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal({'[c', bang = true})
                else
                    gitsigns.nav_hunk('prev')
                end
            end, { desc = "Git: Prev Hunk" })


            map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Git: Stage Hunk" })
            map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Git: Reset Hunk" })

            map('v', '<leader>hs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = "Git: Stage Hunk (Visual)" })

            map('v', '<leader>hr', function()
                gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = "Git: Reset Hunk (Visual)" })

            map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Git: Stage Buffer" })
            map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Git: Reset Buffer" })
            map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Git: Preview Hunk" })
            map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Git: Preview Hunk Inline" })

            map('n', '<leader>hb', function()
                gitsigns.blame_line({ full = true })
            end, { desc = "Git: Blame Line (Full)" })

            map('n', '<leader>hd', gitsigns.diffthis, { desc = "Git: Diff Against Index" })
            map('n', '<leader>hD', function()
                gitsigns.diffthis('~')
            end, { desc = "Git: Diff Against Last Commit" })

            map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, { desc = "Git: Set QF List (All)" })
            map('n', '<leader>hq', gitsigns.setqflist, { desc = "Git: Set QF List (Buffer)" })

            map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Git: Toggle Current Line Blame" })
            map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = "Git: Toggle Word Diff" })
            map('n', '<leader>tl', gitsigns.toggle_linehl, { desc = "Git: Toggle Line Highlight" })
            map('n', '<leader>tn', gitsigns.toggle_numhl, { desc = "Git: Toggle Number Highlight" })
            map({'o', 'x'}, 'ih', gitsigns.select_hunk, { desc = "Git: Select Hunk" })
        end
    })
end