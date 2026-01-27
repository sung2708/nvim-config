local M = require("helper.utils")
local toggleterm = M.safe_require("toggleterm")

if not toggleterm then
    return
end

-- =============================================================================
-- 2. SHELL CONFIGURATION FOR WINDOWS
-- =============================================================================
local shell_executable = vim.o.shell
if vim.fn.has("win32") == 1 then
    if vim.fn.executable("pwsh") == 1 then
        shell_executable = "pwsh"
    else
        shell_executable = "powershell"
    end

    vim.opt.shell = shell_executable
    vim.opt.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command " ..
        "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
    vim.opt.termguicolors = true
end

-- =============================================================================
-- 3. SETUP TOGGLETERM
-- =============================================================================
toggleterm.setup({
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,
    open_mapping = [[<C-\>]], -- Default keybinding to open terminal
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = false,   -- Allow <C-\> to work in insert mode
    terminal_mappings = true, -- Allow <C-\> to work in terminal mode
    persist_size = true,
    persist_mode = true,
    direction = "float",      -- Default to opening in floating window
    close_on_exit = true,
    shell = shell_executable,
    auto_scroll = true,
    float_opts = {
        border = "curved",
        winblend = 3,
    },
    winbar = {
        enabled = false,
    },
})

-- =============================================================================
-- 4. DEFINE CUSTOM TERMINALS (Using Terminal class)
-- =============================================================================
local Terminal = require("toggleterm.terminal").Terminal

-- Python REPL
local python = Terminal:new({
    cmd = "python",
    direction = "horizontal",
    hidden = true,
})

function _PYTHON_TOGGLE()
    python:toggle()
end

-- =============================================================================
-- 5. KEYMAPS (Normal Mode)
-- =============================================================================
local opts = { noremap = true, silent = true }

-- Custom Apps
vim.keymap.set("n", "<leader>py", _PYTHON_TOGGLE, { desc = "Terminal: Python REPL" })

-- Toggle different directions
vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal: Vertical" })
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })

-- Send lines to terminal
local trim_spaces = true
vim.keymap.set("v", "<space>s", function()
    require("toggleterm").send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
end, { desc = "Terminal: Send Selection" })

-- =============================================================================
-- 6. TERMINAL MODE MAPPINGS (Navigation inside Terminal)
-- =============================================================================
function _G.set_terminal_keymaps()
    local t_opts = { buffer = 0 }
    -- Exit terminal mode with <esc> or jk
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], t_opts)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], t_opts)
    
    -- Quickly navigate between splits from terminal
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], t_opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], t_opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], t_opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], t_opts)
    vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], t_opts)
end

-- Only apply navigation keymaps for toggleterm buffers
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*toggleterm#*",
    callback = set_terminal_keymaps,
})

-- =============================================================================
-- 7. COMMANDS
-- =============================================================================
vim.cmd([[command! -count=1 TermGitPush  lua require'toggleterm'.exec("git push",    <count>, 12)]])
vim.cmd([[command! -count=1 TermGitPushF lua require'toggleterm'.exec("git push -f", <count>, 12)]])
