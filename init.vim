" 1. CORE SETTINGS
" ============================================================================
set number
set relativenumber
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set mouse=a
set encoding=UTF-8
set cursorline
set noautochdir
let mapleader = " "
set termguicolors
set hidden
set updatetime=300

if has('win32')
    set clipboard=unnamed  
else
    set clipboard=unnamedplus
endif

au CursorHold,CursorHoldI * checktime
au FocusGained,BufEnter * :checktime
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" ============================================================================
" 2. PLUGIN MANAGEMENT
" ============================================================================
call plug#begin(stdpath('data') . '/plugged')

Plug 'folke/tokyonight.nvim'
Plug 'navarasu/onedark.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'nvim-tree/nvim-web-devicons'
Plug 'folke/noice.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'echasnovski/mini.indentscope'
Plug 'ap/vim-css-color'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'xiyaowong/transparent.nvim'

Plug 'neoclide/coc.nvim', {'branch': 'release','do': 'yarn install --frozen-lockfile'}
Plug 'github/copilot.vim'

Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'folke/flash.nvim'
Plug 'folke/which-key.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'master'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects', {'branch': 'main'}
Plug 'folke/todo-comments.nvim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'terryma/vim-multiple-cursors'

Plug 'voldikss/vim-floaterm'
Plug 'lifepillar/pgsql.vim'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

call plug#end()

" ============================================================================
" 3. UI & KEYBINDINGS
" ============================================================================
syntax on


nnoremap <C-n> :Neotree filesystem reveal left<CR>
nnoremap <C-t> :Neotree toggle<CR>
nnoremap <C-f> :Neotree focus<CR>

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <silent> <esc> :noh<return><esc>
nnoremap <leader>fe <cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>

let g:floaterm_autocmd_bufenter = 0
let g:floaterm_wintype = 'float'
let g:floaterm_position = 'topright'
let g:floaterm_width = 0.6
let g:floaterm_height = 0.8
if has('win32') | let g:floaterm_shell = 'pwsh' | endif

nnoremap <silent> <leader>to :FloatermNew<CR>
nnoremap <silent> <leader>tt :FloatermToggle<CR>
tnoremap <silent> <leader>tt <C-\><C-n>:FloatermToggle<CR>
nnoremap <silent> <leader>gl :FloatermNew! --position=bottomright --height=0.95 --width=0.7 --title='GitLog' git lg<CR>

" ============================================================================
" 4. COC & COPILOT LOGIC
" ============================================================================
let g:coc_global_extensions = ['coc-pyright', 'coc-tsserver', 'coc-json', 'coc-html', 'coc-css', 'coc-prettier', 'coc-vimlsp']
let g:copilot_no_tab_map = v:true

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#confirm() :
      \ exists('b:_copilot.suggestions') && copilot#GetDisplayedSuggestion().text != "" ? copilot#Accept("\<Tab>") :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

imap <silent><script><expr> <M-\> copilot#Accept("\<CR>")

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> <leader>rn <Plug>(coc-rename)

" Using shift tab for copilot
inoremap <silent><expr> <S-Tab> copilot#Previous()

nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" ============================================================================
" 5. Todo COMMENTS HIGHLIGHTING
" ============================================================================
nnoremap <leader>xt :TodoTelescope<CR>
nnoremap <leader>xq :TodoQuickFix<CR>

runtime! plugged/nvim-treesitter/plugin/nvim-treesitter.lua
runtime! plugged/nvim-treesitter-textobjects/plugin/nvim-treesitter-textobjects.vim

" ============================================================================
" 6 Coc SETTINGS
" ============================================================================
inoremap <silent><expr> <C-Space> coc#refresh()
nmap <silent> <leader>ca <Plug>(coc-codeaction-cursor)
vmap <silent> <leader>ca <Plug>(coc-codeaction-selected)

"===========================================================================
" 7. ADDITIONAL SETTINGS
" ============================================================================
nnoremap <C-Up> :resize +2<CR>
nnoremap <C-Down> :resize -2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" bufferline
nnoremap <silent> <leader>1 :BufferLineGoToBuffer 1<CR>
nnoremap <silent> <leader>2 :BufferLineGoToBuffer 2<CR>
nnoremap <silent> <leader>3 :BufferLineGoToBuffer 3<CR>
nnoremap <silent> <leader>4 :BufferLineGoToBuffer 4<CR>

nnoremap <silent> <leader>bn :BufferLineMoveNext<CR>
nnoremap <silent> <leader>bp :BufferLineMovePrev<CR>
nnoremap <silent> <leader>bl :BufferLineCloseLeft<CR>
nnoremap <silent> <leader>br :BufferLineCloseRight<CR>
" ============================================================================
" 7. LUA CONFIGURATIONS
" ============================================================================

lua << EOF
_G.safe_require = function(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify("Failed to load " .. mod, vim.log.levels.WARN)
    return nil
  end
  return m
end

local status, telescope = pcall(require, "telescope")
if not status then return end

telescope.setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    ['ui-select'] = {
      require("telescope.themes").get_dropdown {}
    },
    ['file_browser'] = {
      hijack_netrw = true,
    }
  },
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "file_browser")
pcall(telescope.load_extension, "ui-select")

local status, configs = pcall(require, "nvim-treesitter.configs")
if not status then return end

configs.setup {
  select = {
    -- Automatically jump forward to textobj, similar to targets.vim
    lookahead = true,
    -- You can choose the select mode (default is charwise 'v')
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * method: eg 'v' or 'o'
    -- and should return the mode ('v', 'V', or '<c-v>') or a table
    -- mapping query_strings to modes.
    selection_modes = {
      ['@parameter.outer'] = 'v', -- charwise
      ['@function.outer'] = 'V', -- linewise
      -- ['@class.outer'] = '<c-v>', -- blockwise
    },
    -- If you set this to `true` (default is `false`) then any textobject is
    -- extended to include preceding or succeeding whitespace. Succeeding
    -- whitespace has priority in order to act similarly to eg the built-in
    -- `ap`.
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * selection_mode: eg 'v'
    -- and should return true of false
    include_surrounding_whitespace = false,
  },
  move = {
    -- whether to set jumps in the jumplist
    set_jumps = true,
  },
}
safe_require('lualine').setup()
safe_require('bufferline').setup()
local status, notify = pcall(require, "notify")
if status then
    notify.setup({
        background_colour = "#1e1e2e", 
        timeout = 3000,
        render = "default",
    })
end
safe_require('mini.indentscope').setup()


local noice = safe_require("noice")
if noice then
    noice.setup({
        -- Disable LSP-specific overrides since you use CoC
        lsp = {
            progress = { enabled = false },
            signature = { enabled = false },
            hover = { enabled = false },
        },
        -- Keep the beautiful Command Line and Search UI
        presets = {
            bottom_search = true, 
            command_palette = true, 
            long_message_to_split = true,
            inc_rename = false, -- CoC handles its own renaming UI
        },
        -- Ensure Noice doesn't conflict with CoC's floating windows
        popupmenu = {
            enabled = true, -- This is for Neovim's cmdline popup, not CoC's
            backend = "nui",
        },
    })
end
local todo = safe_require("todo-comments")
if todo then
    todo.setup({ highlight = { keyword = "wide", after = "fg", pattern = [[.*<(KEYWORDS)\s*:]] } })
    vim.keymap.set("n", "]t", function() todo.jump_next() end)
    vim.keymap.set("n", "[t", function() todo.jump_prev() end)
end

local flash = safe_require("flash")
if flash then
    vim.keymap.set({"n", "x", "o"}, "s", function() flash.jump() end)
    vim.keymap.set({"n", "x", "o"}, "S", function() flash.treesitter() end)
end

local neotree = safe_require("neo-tree")
if neotree then
    neotree.setup({
        close_if_last_window = true,
        filesystem = {
            filtered_items = { visible = true, hide_dotfiles = false },
            follow_current_file = { enabled = true },
        }
    })
end
vim.keymap.set({ "x", "o" }, "am", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "im", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end)
-- You can also use captures from other query groups like `locals.scm`
vim.keymap.set({ "x", "o" }, "as", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
end)
vim.keymap.set("n", "<leader>a", function()
  require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
end)
vim.keymap.set("n", "<leader>A", function()
  require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]m", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]]", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
end)
-- You can also pass a list to group multiple queries.
vim.keymap.set({ "n", "x", "o" }, "]o", function()
  require("nvim-treesitter-textobjects.move").goto_next_start({"@loop.inner", "@loop.outer"}, "textobjects")
end)
-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
vim.keymap.set({ "n", "x", "o" }, "]s", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
end)
vim.keymap.set({ "n", "x", "o" }, "]z", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
end)

vim.keymap.set({ "n", "x", "o" }, "]M", function()
  require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "][", function()
  require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[m", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[[", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[M", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[]", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
end)

-- Go to either the start or the end, whichever is closer.
-- Use if you want more granular movements
vim.keymap.set({ "n", "x", "o" }, "]d", function()
  require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[d", function()
  require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects")
end)

local status, transparent = pcall(require, "transparent")
if status then
  transparent.setup({
    enable = true, 
    groups = {
      'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
      'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
      'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
      'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
      'EndOfBuffer',
    },
    -- Gộp tất cả các nhóm bổ sung (như BufferLine) vào một nơi duy nhất
   extra_groups = {
            "Floaterm",
            "FloatermBorder",
            "FloatermNC",

            "NeoTreeNormal",
            "NeoTreeNormalNC",
            "NeoTreeWinSeparator",
            "NeoTreeEndOfBuffer",

            "BufferLineTabClose",
            "BufferLineBufferSelected",
            "BufferLineFill",
            "BufferLineBackground",
            "BufferLineSeparator",

            "StatusLine",
            "StatusLineNC",
            "TelescopeNormal",
            "TelescopeBorder",
            "NormalFloat",
            "FloatBorder",

			"NotifyBackground", 
            "NotifyNormal",
			}, 
	exclude_groups = {
            "CursorLine",   -- Giữ lại highlight của dòng hiện tại
            "CursorLineNr", -- Giữ lại highlight số dòng của dòng hiện tại
        },
  })
end

local bufferline = safe_require("bufferline")
if bufferline then
	bufferline.setup({
		options = {
			show_buffer_close_icons = false,
			show_close_icon = false,
		},
	})
end

EOF

colorscheme catppuccin-mocha
