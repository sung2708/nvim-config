" ============================================================================
" 1. BASIC SETTINGS
" ============================================================================
let g:copilot_enabled = 0
set number
set relativenumber
set cursorline
set cursorcolumn
set termguicolors
set signcolumn=yes
set laststatus=3
set scrolloff=4
set nolist
set mouse=a

set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab

set ignorecase
set smartcase
set incsearch
set hlsearch

set encoding=UTF-8
set hidden
set updatetime=200
set confirm
let mapleader = " "

if has('win32')
    set clipboard=unnamed  
else
    set clipboard=unnamedplus
endif

set nobackup
set nowb
set noswapfile
set undofile

set splitright
set splitbelow

set foldlevel=99
set foldmethod=indent

filetype plugin indent on
au CursorHold,CursorHoldI * checktime
au FocusGained,BufEnter * :checktime

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

vnoremap < <gv
vnoremap > >gv

nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <silent> <esc> :noh<return><esc>

nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)
nnoremap <silent> <leader>e :call CocActionAsync('doHover')<CR>

nnoremap <C-Up> :resize +2<CR>
nnoremap <C-Down> :resize -2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" ============================================================================
" 2. PLUGIN MANAGEMENT
" ============================================================================
call plug#begin(stdpath('data') . '/plugged')

Plug 'folke/tokyonight.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'nvim-tree/nvim-web-devicons'
Plug 'folke/noice.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'shellRaining/hlchunk.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'

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
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'terryma/vim-multiple-cursors'

Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}

Plug 'tpope/vim-surround'
Plug 'folke/ts-comments.nvim'

Plug 'windwp/nvim-ts-autotag'

Plug 'nvim-mini/mini.animate', { 'branch': 'stable' }
Plug 'folke/edgy.nvim'
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'lewis6991/gitsigns.nvim'
call plug#end()
" ============================================================================
" 3. UI & KEYBINDINGS
" ============================================================================
syntax on

nnoremap <silent><C-n>:Neotree filesystem reveal left<CR>
nnoremap <silent><C-t> :Neotree toggle<CR>
nnoremap <silent><C-f> :Neotree focus<CR>

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <silent> <esc> :noh<return><esc>
nnoremap <leader>fe <cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>
" ===========================================================================
" 4. COC & COPILOT LOGIC
" ============================================================================
let g:coc_global_extensions = ['coc-pyright', 'coc-tsserver', 'coc-json', 'coc-html', 'coc-css', 'coc-prettier', 'coc-vimlsp']
let g:copilot_no_tab_map = v:true

inoremap <silent><expr> <TAB>
      \ copilot#Accept("\<CR>") !=# "\<CR>" ? copilot#Accept("\<TAB>") :
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
let g:coc_snippet_next = '<tab>'

imap <silent><script><expr> <M-\> copilot#Accept("\<CR>")

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> <leader>rn <Plug>(coc-rename)
nnoremap <silent> K :call CocActionAsync('doHover')<CR>


inoremap <silent><expr> <C-Space> coc#refresh()
nmap <silent> <leader>ca <Plug>(coc-codeaction-cursor)
vmap <silent> <leader>ca <Plug>(coc-codeaction-selected)
imap <C-l> <Plug>(coc-snippets-expand)
vmap <C-j> <Plug>(coc-snippets-select)
let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<s-tab>'
imap <C-j> <Plug>(coc-snippets-expand-jump)
xmap <leader>x  <Plug>(coc-convert-snippet)
" ============================================================================
" 5. Todo COMMENTS HIGHLIGHTING
" ============================================================================
nnoremap <leader>xt :TodoTelescope<CR>
nnoremap <leader>xq :TodoQuickFix<CR>

runtime! plugged/nvim-treesitter/plugin/nvim-treesitter.lua
runtime! plugged/nvim-treesitter-textobjects/plugin/nvim-treesitter-textobjects.vim
" ============================================================================
" 6. BUFFERLINE SETTINGS & KEYBINDINGS
" ============================================================================
nnoremap <silent> <C-p> :BufferLineTogglePin<CR>
nnoremap <silent> <Tab> :BufferLineCycleNext<CR>
nnoremap <silent> <S-Tab> :BufferLineCyclePrev<CR>
nnoremap <silent> <leader>bc :bdelete<CR>
nnoremap <silent> <leader>be :BufferLineMoveNext<CR>
nnoremap <silent> <leader>bq :BufferLineMovePrev<CR>
" ============================================================================
" 8. LUA CONFIGURATIONS
" ============================================================================
lua << EOF

local M = require("helper.utils")

local catppuccin = M.safe_require("catppuccin")
if catppuccin then
    catppuccin.setup({
        transparent_background = true,
    })
end

local lualine = M.safe_require("lualine")
if lualine then
    lualine.setup()
end

local markdown = M.safe_require("render-markdown")
if markdown then
	markdown.setup()
end

local auto_tag = M.safe_require("nvim-ts-autotag")
if auto_tag then
    auto_tag.setup({
        opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = false,
        },
    })
end


EOF

colorscheme catppuccin-frappe
