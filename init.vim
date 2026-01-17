" ============================================================================
" 1. THIẾT LẬP HỆ THỐNG (CORE SETTINGS)
" ============================================================================
set number
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set mouse=a
set encoding=UTF-8
set cursorline
set noautochdir " Vô hiệu hóa để tránh lỗi E5555 khi mở Floaterm
let mapleader = " "

" Clipboard: Hỗ trợ Windows và Linux/WSL
if has('win32')
  set clipboard=unnamed  
else
  set clipboard=unnamedplus
endif

" Tự động tải lại file khi có thay đổi từ bên ngoài (Disk change)
au CursorHold,CursorHoldI * checktime
au FocusGained,BufEnter * :checktime
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
    \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == ''
    \ | checktime 
    \ | endif
autocmd FileChangedShellPost *
    \ echohl WarningMsg 
    \ | echo "File changed on disk. Buffer reloaded."
    \ | echohl None

" ============================================================================
" 2. QUẢN LÝ PLUGIN (VIM-PLUG)
" ============================================================================
call plug#begin()

" Giao diện & Màu sắc
Plug 'navarasu/onedark.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'ap/vim-css-color'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'echasnovski/mini.indentscope'
Plug 'folke/tokyonight.nvim'

" Status bar & Themes
Plug 'nvim-lualine/lualine.nvim'

" LSP, Autocomplete & Snippets
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'github/copilot.vim'

" File Explorer & Navigation
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }

" Tiện ích soạn thảo
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'terryma/vim-multiple-cursors'
Plug 'folke/which-key.nvim'
Plug 'folke/flash.nvim'

" Ngôn ngữ & Databases
Plug 'lifepillar/pgsql.vim'
Plug 'yuezk/vim-js'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'

" Terminal
Plug 'voldikss/vim-floaterm'

call plug#end()

" ============================================================================
" 3. CẤU HÌNH GIAO DIỆN (UI)
" ============================================================================
syntax on
colorscheme tokyonight

" Khắc phục lỗi airline_c_bold
autocmd ColorScheme * highlight link airline_c_bold airline_c

" Airline Symbols (Các ký tự đặc biệt)
if !exists('g:airline_symbols') | let g:airline_symbols = {} | endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''

" ============================================================================
" 4. CẤU HÌNH NERDTREE (CHI TIẾT)
" ============================================================================
nnoremap <C-n> :Neotree filesystem reveal left<CR>
nnoremap <C-t> :Neotree toggle<CR>
nnoremap <C-f> :Neotree focus<CR>

" Tự động thoát nếu chỉ còn NERDTree
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Git status icons cho NERDTree
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  :'✹', 'Staged'    :'✚', 'Untracked' :'✭',
    \ 'Renamed'   :'➜', 'Unmerged'  :'═', 'Deleted'   :'✖',
    \ 'Dirty'     :'✗', 'Ignored'   :'☒', 'Clean'     :'✔︎', 'Unknown'   :'?',
    \ }

" ============================================================================
" 5. CẤU HÌNH COC & COPILOT (LOGIC TAB)
" ============================================================================

let g:copilot_no_tab_map = v:true

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#confirm() :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

imap <silent><script><expr> <S-Tab> copilot#Accept("\<S-Tab>")

let g:coc_global_extensions = ['coc-tslint-plugin', 'coc-tsserver', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-pyright']

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Tab thông minh: Ưu tiên Popup CoC -> Copilot -> Refresh CoC -> Tab thường
inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#confirm() :
      \ exists('b:_copilot.suggestions') && copilot#GetDisplayedSuggestion().text != "" ? copilot#Accept("\<Tab>") :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

let g:copilot_no_tab_map = v:true
imap <silent><script><expr> <M-\> copilot#Accept("\<CR>")

" LSP Mappings
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover') | call CocActionAsync('doHover')
  else | call feedkeys('K', 'in') | endif
endfunction

" ============================================================================
" 6. CẤU HÌNH FLOATTERM (SỬA LỖI TOGGLE & LCD)
" ============================================================================
let g:floaterm_autocmd_bufenter = 0 " Sửa lỗi E5555
let g:floaterm_wintype = 'float'
let g:floaterm_position = 'topright'
let g:floaterm_width = 0.6
let g:floaterm_height = 0.8
let g:floaterm_title = 'Terminal $1/$2'

if has('win32')
    let g:floaterm_shell = 'pwsh'
endif

" Phím tắt Terminal
nnoremap <silent> <leader>to :FloatermNew<CR>
tnoremap <silent> <leader>to <C-\><C-n>:FloatermNew<CR>
nnoremap <silent> <leader>tk :FloatermKill<CR>
tnoremap <silent> <leader>tk <C-\><C-n>:FloatermKill<CR>
nnoremap <silent> <leader>tn :FloatermNext<CR>
tnoremap <silent> <leader>tn <C-\><C-n>:FloatermNext<CR>
nnoremap <silent> <leader>tp :FloatermPrev<CR>
tnoremap <silent> <leader>tp <C-\><C-n>:FloatermPrev<CR>
nnoremap <silent> <leader>tt :FloatermToggle<CR>
tnoremap <silent> <leader>tt <C-\><C-n>:FloatermToggle<CR>

" Git Log nhanh qua Floaterm
nnoremap <silent> <leader>gl :FloatermNew! --position=bottomright --height=0.95 --width=0.7 --title='GitLog' git lg<CR>

" ============================================================================
" 7. TELESCOPE & NHẢY NHANH
" ============================================================================
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

nnoremap <silent> <esc> :noh<return><esc>
nmap <F8> :TagbarToggle<CR>

" ============================================================================
" 8. CẤU HÌNH LUA (FLASH.NVIM)
" ============================================================================
lua << EOF
require("flash").setup({
  labels = "asdfghjklqwertyuiopzxcvbnm",
  search = { multi_window = true, forward = true, wrap = true },
  modes = { char = { enabled = true, jump_labels = true } },
})
vim.keymap.set({"n", "x", "o"}, "s", function() require("flash").jump() end)
vim.keymap.set({"n", "x", "o"}, "S", function() require("flash").treesitter() end)
vim.keymap.set("o", "r", function() require("flash").remote() end)

require('mini.indentscope').setup()

require('lualine').setup()

require("neo-tree").setup({
  close_if_last_window = true,
  filesystem = {
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    follow_current_file = {
        enabled = true,
    },
  },
  window = {
    width = 30,
    mappings = {
      ["<space>"] = "none",
    }
  }
})

EOF
