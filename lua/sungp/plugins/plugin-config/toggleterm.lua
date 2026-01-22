local M = require("sungp.helper.utils")

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
        local toggleterm = M.safe_require("toggleterm")
        if not toggleterm then return end

        toggleterm.setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<C-\>]], -- Default keybinding to toggle terminal
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = "float", -- Default direction
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "curved", -- Rounded border for aesthetics
                winblend = 3,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                },
            },
        })

        -- =============================================================================
        -- CONFIGURING CUSTOM TERMINALS
        -- =============================================================================
        local Terminal = require("toggleterm.terminal").Terminal

        -- 1. Lazygit (Open in floating window)
        local lazygit = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            float_opts = { border = "double" },
            on_open = function(term)
                vim.cmd("startinsert!")
                -- Disable default terminal exit key inside lazygit to avoid conflicts
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
            end,
        })

        function _LAZYGIT_TOGGLE()
            lazygit:toggle()
        end

        -- 2. Python (For quick script running)
        local python = Terminal:new({ cmd = "python", direction = "horizontal" })
        function _PYTHON_TOGGLE()
            python:toggle()
        end

        -- =============================================================================
        -- ADVANCED KEYMAPS
        -- =============================================================================
        local opts = { noremap = true, silent = true }

        -- Quick keybindings for Lazygit and Python
        vim.keymap.set("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { desc = "Git: Toggle Lazygit" })
        vim.keymap.set("n", "<leader>py", "<cmd>lua _PYTHON_TOGGLE()<CR>", { desc = "Terminal: Python REPL" })

        -- Keybindings to open Terminal in different directions
        vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
        vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal: Vertical" })
        vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })

        -- Terminal Mappings (Terminal mode)
        function _G.set_terminal_keymaps()
            local t_opts = { buffer = 0 }
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], t_opts) -- Exit insert mode in terminal
            vim.keymap.set('t', 'jk', [[<C-\><C-n>]], t_opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], t_opts) -- Move left
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], t_opts) -- Move down
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], t_opts) -- Move up
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], t_opts) -- Move right
        end

        -- Apply movement keymaps only when terminal is open
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end,
}