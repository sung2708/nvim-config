local M = require("helper.utils")
local toggleterm = M.safe_require("toggleterm")

if not toggleterm then
    return
end

-- =============================================================================
-- 1. SHELL CONFIGURATION (Cross-platform support)
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
end

-- Force termguicolors for better highlight support
vim.opt.termguicolors = true

-- =============================================================================
-- 2. GLOBAL TRANSPARENCY FIX
-- =============================================================================
-- This function ensures that floating windows stay transparent even if 
-- the colorscheme tries to override them.
local function force_transparent()
    local hl_groups = { "NormalFloat", "FloatBorder" }
    for _, group in ipairs(hl_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
    end
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
    open_mapping = [[<C-\>]], 
    hide_numbers = true,
    shade_terminals = false,      -- Required for transparency
    shading_factor = 0,           -- Prevent automatic darkening
    start_in_insert = true,
    insert_mappings = false,      
    terminal_mappings = true,     
    persist_size = true,
    persist_mode = true,
    direction = "float",          
    close_on_exit = true,
    shell = shell_executable,
    auto_scroll = true,
    float_opts = {
        border = "curved",
        winblend = 0,             -- 0 is fully transparent
    },
    winbar = {
        enabled = false,
    },
    highlights = {
        -- Use 'none' to allow the terminal emulator background to show through
        NormalFloat = {
            link = 'Normal'
        },
        FloatBorder = {
            guibg = "none",
        },
    },
})

-- =============================================================================
-- 4. CUSTOM TERMINAL INSTANCES
-- =============================================================================
local Terminal = require("toggleterm.terminal").Terminal

-- Helper to create terminals with transparency settings
local function create_custom_term(opts)
    opts.float_opts = opts.float_opts or {}
    opts.float_opts.winblend = 0  -- Force transparency for custom terms
    return Terminal:new(opts)
end

-- Python REPL
local python = create_custom_term({
    cmd = "uv run",
    direction = "horizontal",
    hidden = true,
})

function _PYTHON_TOGGLE()
    python:toggle()
end

-- LazyGit
local lazygit = create_custom_term({ 
    cmd = "lazygit", 
    direction = "float",
    hidden = true 
})

function _lazygit_toggle()
    lazygit:toggle()
end

-- LazyDocker
local lazydocker = create_custom_term({
    cmd = "lazydocker", 
    direction = "float",
    hidden = true 
})

function _lazydocker_toggle()
    lazydocker:toggle()
end

-- =============================================================================
-- 5. KEYMAPS (Normal Mode)
-- =============================================================================
local opts = { noremap = true, silent = true }

-- Custom Apps
vim.keymap.set("n", "<leader>py", _PYTHON_TOGGLE, { desc = "Terminal: Python REPL" })
vim.keymap.set("n", "<leader>g", _lazygit_toggle, { desc = "Terminal: Lazygit" })
vim.keymap.set("n", "<leader>d", _lazydocker_toggle, { desc = "Terminal: Lazydocker" })

-- Toggle different directions
vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal: Vertical" })
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })

-- Send visual selection to terminal
vim.keymap.set("v", "<space>s", function()
    require("toggleterm").send_lines_to_terminal("visual_selection", true, { args = vim.v.count })
end, { desc = "Terminal: Send Selection" })

-- =============================================================================
-- 6. TERMINAL MODE MAPPINGS & AUTOCMDS
-- =============================================================================
function _G.set_terminal_keymaps()
    local t_opts = { buffer = 0 }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], t_opts)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], t_opts)
    
    -- Navigation
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], t_opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], t_opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], t_opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], t_opts)
end

-- Apply keymaps and force transparency when terminal opens
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*toggleterm#*",
    callback = function()
        set_terminal_keymaps()
        force_transparent() -- Ensure it's transparent every time it opens
    end,
})

-- =============================================================================
-- 7. CUSTOM COMMANDS
-- =============================================================================
vim.cmd([[command! -count=1 TermGitPush  lua require'toggleterm'.exec("git push",    <count>, 12)]])
vim.cmd([[command! -count=1 TermGitPushF lua require'toggleterm'.exec("git push -f", <count>, 12)]])

-- Final call to ensure transparency on load
force_transparent()
