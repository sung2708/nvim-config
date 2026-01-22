-- =============================================================================
-- KEYMAPS
-- =============================================================================
vim.opt.termguicolors = true
vim.g.AutoPairsFlyMode = 0
vim.g.AutoPairsShortcutBackInsert = '<M-b>'
vim.cmd("filetype plugin indent on")

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Resize window using Ctrl + Arrow keys
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- =============================================================================
-- GENERAL SETTINGS
-- =============================================================================
local opt = vim.opt

-- Interface & Display
opt.number = true           -- Show line numbers
opt.relativenumber = true   -- Relative line numbers (helpful for quick movement)
opt.cursorline = true       -- Highlight current line
opt.cursorcolumn = true     -- Highlight current column
opt.termguicolors = true    -- Enable 24-bit colors
opt.showmode = false        -- Don't show mode (because statusline already shows it)
opt.laststatus = 3          -- Global statusline (nvim 0.7+)
opt.signcolumn = "yes"      -- Always show sign column to avoid code shifting

-- Encoding & System
vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.mouse = "a"             -- Enable mouse
opt.updatetime = 200        -- Faster response time
opt.timeoutlen = 300        -- Key sequence timeout
opt.hidden = true           -- Allow switching buffers without saving
opt.confirm = true          -- Confirm before exiting if there are unsaved changes
opt.clipboard = (vim.env.SSH_TTY == nil) and "unnamedplus" or "" -- Synchronize clipboard

-- Tab & Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true        -- Use spaces instead of tabs
opt.smartindent = true      -- Automatically indent intelligently
opt.autoindent = true

-- Tìm kiếm
opt.ignorecase = true       -- Ignore case when searching
opt.smartcase = true        -- If there are uppercase letters, search is case-sensitive
opt.incsearch = true        -- Search as you type
opt.hlsearch = true         -- Highlight search results

-- Backup & Undo
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true         -- Save undo history even when the machine is turned off
opt.undolevels = 10000

-- Window Splitting
opt.splitright = true       -- Vertical split is located on the right
opt.splitbelow = true       -- Horizontal split is located underneath

-- Scrolling & Wrapping
opt.scrolloff = 4           -- Keep 4 lines when scrolling up/down
opt.sidescrolloff = 8
opt.wrap = false            -- Doesn't automatically go down the line when it's long
opt.linebreak = true

-- Folding (Gập code)
opt.foldlevel = 99
opt.foldmethod = "indent"
if vim.fn.has("nvim-0.10") == 1 then
  opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
end

-- =============================================================================
-- AUTOCOMMANDS
-- =============================================================================

-- Automatically check for external file changes (checktime)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "checktime",
})

-- Disable automatic commenting on new lines (formatoptions)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Fix highlight issue for Terminal
vim.api.nvim_create_autocmd("TermOpen", {
  command = "setlocal winhighlight=Normal:Normal",
})

-- Hover highlight for current word under cursor
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" },
      border = "rounded",
      source = "always",
      prefix = " ",
      scope = "cursor",
    })
  end,
})

-- =============================================================================
-- MISCELLANEOUS SETTINGS
-- =============================================================================
vim.g.autoformat = true
vim.g.markdown_recommended_style = 0
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
opt.fillchars = { fold = " ", eob = " ", diff = "╱" }