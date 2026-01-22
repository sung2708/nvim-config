local M = require("helper.utils")

local toggleterm = M.safe_require("toggleterm")
if not toggleterm then
    return
end

-- =============================================================================
-- SHELL CONFIG (WINDOWS)
-- =============================================================================
local shell_executable = "powershell"
if vim.fn.executable("pwsh") == 1 then
    shell_executable = "pwsh"
end

if vim.fn.has("win32") == 1 then
    vim.opt.shell = shell_executable
    vim.opt.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command " ..
        "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
end

-- =============================================================================
-- TOGGLETERM SETUP
-- =============================================================================
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
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = shell_executable,
    float_opts = {
        border = "curved",
        winblend = 3,
    },
})

-- =============================================================================
-- CUSTOM TERMINALS
-- =============================================================================
local Terminal = require("toggleterm.terminal").Terminal

-- Python REPL
local python = Terminal:new({
    cmd = "python",
    direction = "horizontal",
})

function _PYTHON_TOGGLE()
    python:toggle()
end

-- =============================================================================
-- KEYMAPS
-- =============================================================================
vim.keymap.set("n", "<leader>py", _PYTHON_TOGGLE, { desc = "Terminal: Python" })

vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal: Vertical" })
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })

-- =============================================================================
-- TERMINAL MODE KEYMAPS
-- =============================================================================
local function set_terminal_keymaps()
    local opts = { buffer = true }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", opts)
    vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", opts)
    vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", opts)
    vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", opts)
end

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = set_terminal_keymaps,
})
