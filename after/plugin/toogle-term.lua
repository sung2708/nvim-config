local M = require("helper.utils")

local toggleterm = M.safe_require("toggleterm")
if toggleterm then
    -- 1. Cấu hình để sử dụng pwsh làm shell mặc định cho cả Neovim và ToggleTerm
    local shell_executable = "powershell" -- Giá trị mặc định
    if vim.fn.executable("pwsh") == 1 then
        shell_executable = "pwsh"
    end

    -- Thiết lập options cho PowerShell để hỗ trợ UTF8 và chạy script mượt mà
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
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        open_mapping = [[<C-\>]], 
        hide_numbers = true,
        shade_terminals = false, -- Để nền không bị tối màu
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float", 
        close_on_exit = true,
        shell = shell_executable, -- Sử dụng pwsh ở đây
        float_opts = {
            border = "curved", 
            winblend = 0, -- Loại bỏ độ trong suốt gây lệch màu
            highlights = {
                border = "FloatBorder",
                background = "NormalFloat", 
            },
        },
    })

    -- =============================================================================
    -- CONFIGURING CUSTOM TERMINALS
    -- =============================================================================
    local Terminal = require("toggleterm.terminal").Terminal

    -- 1. Lazygit
    local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        shell = shell_executable,
        float_opts = { 
            border = "double",
            winblend = 0,
        },
        on_open = function(term)
            vim.cmd("startinsert!")
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
    })

    function _LAZYGIT_TOGGLE()
        lazygit:toggle()
    end

    -- 2. Python (Dùng cho các dự án Python của bạn tại HDWEBSOFT)
    local python = Terminal:new({ 
        cmd = "python", 
        shell = shell_executable,
        direction = "horizontal",
        size = 15,
    })
    function _PYTHON_TOGGLE()
        python:toggle()
    end

    -- =============================================================================
    -- ADVANCED KEYMAPS
    -- =============================================================================
    local map = vim.keymap.set

    map("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { desc = "Git: Toggle Lazygit" })
    map("n", "<leader>py", "<cmd>lua _PYTHON_TOGGLE()<CR>", { desc = "Terminal: Python REPL" })

    map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
    map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal: Vertical" })
    map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })
    -- Terminal Mappings
    function _G.set_terminal_keymaps()
        local t_opts = { buffer = 0 }
        map('t', '<esc>', [[<C-\><C-n>]], t_opts)
        map('t', 'jk', [[<C-\><C-n>]], t_opts)
        map('t', '<C-h>', [[<Cmd>wincmd h<CR>]], t_opts)
        map('t', '<C-j>', [[<Cmd>wincmd j<CR>]], t_opts)
        map('t', '<C-k>', [[<Cmd>wincmd k<CR>]], t_opts)
        map('t', '<C-l>', [[<Cmd>wincmd l<CR>]], t_opts)
    end

    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
end
