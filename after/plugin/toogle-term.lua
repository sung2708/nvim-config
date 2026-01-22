local M = require("helper.utils")

local toggleterm = M.safe_require("toggleterm")
if toggleterm then
    local shell_executable = "powershell"
    if vim.fn.executable("pwsh") == 1 then
        shell_executable = "pwsh"
    end

    if vim.fn.has("win32") == 1 then
        vim.opt.shell = shell_executable
        vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
        vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow"
        vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; if($?){local:status=$?}else{local:status=$?}; $status"
        vim.opt.shellquote = ""
        vim.opt.shellxquote = ""
    end

    toggleterm.setup({
        size = function(term)
            if term.direction == "horizontal" then return 15
            elseif term.direction == "vertical" then return vim.o.columns * 0.4 end
        end,
        open_mapping = [[<C-\>]], 
        hide_numbers = true,
        shade_terminals = false,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float", 
        close_on_exit = true,
        shell = shell_executable,
        float_opts = {
            border = "curved", 
            winblend = 0,
            highlights = { border = "FloatBorder", background = "NormalFloat" },
        },
    })

    local Terminal = require("toggleterm.terminal").Terminal

    local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = vim.fn.getcwd(),
        direction = "float",
        float_opts = { border = "double", winblend = 0 },
        on_open = function(term)
            vim.cmd("startinsert!")
            vim.keymap.set('t', 'q', [[<C-\><C-n><cmd>close<cr>]], { buffer = term.bufnr, silent = true })
            vim.keymap.set('t', 'jk', [[jk]], { buffer = term.bufnr })
            vim.keymap.set('t', '<esc>', [[<esc>]], { buffer = term.bufnr })
        end,
    })

    function _LAZYGIT_TOGGLE() lazygit:toggle() end

    -- 2. PYTHON REPL
    local python = Terminal:new({ cmd = "python", direction = "horizontal", size = 15 })
    function _PYTHON_TOGGLE() python:toggle() end

    -- =============================================================================
    -- KEYMAPS & LOGIC
    -- =============================================================================
    local map = vim.keymap.set

    map("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { desc = "Git: Toggle Lazygit" })
    map("n", "<leader>py", "<cmd>lua _PYTHON_TOGGLE()<CR>", { desc = "Terminal: Python" })
    function _G.set_terminal_keymaps()
        local t_opts = { buffer = 0 }
        if vim.bo.filetype ~= "lazygit" then
            map('t', '<esc>', [[<C-\><C-n>]], t_opts)
            map('t', 'jk', [[<C-\><C-n>]], t_opts)
        end
    end

    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
end