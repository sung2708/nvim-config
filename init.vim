" ============================================================================
" 1. BASIC SETTINGS
" ============================================================================
let g:copilot_enabled = 0
let g:nvim_config_home = expand('<sfile>:p:h')
execute 'set runtimepath^=' . fnameescape(g:nvim_config_home)
execute 'set packpath^=' . fnameescape(g:nvim_config_home)
if exists('*luaeval')
    lua vim.loader.enable()
endif
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
set timeoutlen=400
set ttimeoutlen=10
set redrawtime=1500
set synmaxcol=400
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

augroup SungpCorePerformance
    autocmd!
    autocmd FocusGained,BufEnter,CursorHold * checktime
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    autocmd InsertEnter * if &l:cursorcolumn | let b:sungp_restore_cursorcolumn = 1 | setlocal nocursorcolumn | endif | if &l:cursorline | let b:sungp_restore_cursorline = 1 | setlocal nocursorline | endif | if &l:relativenumber | let b:sungp_restore_relativenumber = 1 | setlocal norelativenumber | endif
    autocmd InsertLeave * if get(b:, 'sungp_restore_cursorcolumn', 0) | setlocal cursorcolumn | let b:sungp_restore_cursorcolumn = 0 | endif | if get(b:, 'sungp_restore_cursorline', 0) | setlocal cursorline | let b:sungp_restore_cursorline = 0 | endif | if get(b:, 'sungp_restore_relativenumber', 0) | setlocal relativenumber | let b:sungp_restore_relativenumber = 0 | endif
augroup END

nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l

nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==
vnoremap <leader>j :m '>+1<CR>gv=gv
vnoremap <leader>k :m '<-2<CR>gv=gv

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

nnoremap gO :<C-u>CocList outline<CR>

" ============================================================================
" 2. PLUGIN MANAGEMENT
" ============================================================================
call plug#begin(stdpath('data') . '/plugged')

Plug 'folke/tokyonight.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'nvim-tree/nvim-web-devicons'
Plug 'folke/noice.nvim', { 'on': [] }
Plug 'MunifTanjim/nui.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'shellRaining/hlchunk.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim', { 'on': 'Telescope' }
Plug 'nvim-telescope/telescope-ui-select.nvim', { 'on': 'Telescope' }
Plug 'shaunsingh/nord.nvim'

Plug 'neoclide/coc.nvim', {'branch': 'release','do': 'yarn install --frozen-lockfile'}
Plug 'github/copilot.vim'

Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x', 'on': 'Neotree' }
Plug 'nvim-telescope/telescope.nvim', { 'on': 'Telescope' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'on': 'Telescope', 'do': 'make' }
Plug 'folke/trouble.nvim', { 'on': [] }
Plug 'folke/flash.nvim', { 'on': [] }
Plug 'folke/which-key.nvim'
Plug 'junegunn/fzf', { 'on': ['Files', 'Rg', 'Buffers', 'History'], 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'on': ['Files', 'Rg', 'Buffers', 'History'] }
Plug 'ibhagwan/fzf-lua', { 'on': 'FzfLua' }

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'main'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects', {'branch': 'main'}
Plug 'folke/todo-comments.nvim'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'terryma/vim-multiple-cursors'

Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}

Plug 'tpope/vim-surround'
Plug 'folke/ts-comments.nvim'

Plug 'windwp/nvim-ts-autotag', { 'for': ['html', 'xml', 'javascriptreact', 'typescriptreact', 'vue', 'svelte', 'astro', 'php'] }

Plug 'nvim-mini/mini.animate', { 'branch': 'stable' }
Plug 'folke/edgy.nvim'
Plug 'MeanderingProgrammer/render-markdown.nvim', { 'on': [] }
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive', { 'on': ['Git', 'G', 'Gdiffsplit', 'Gvdiffsplit', 'Gwrite', 'Gread', 'Ggrep', 'Gclog'] }
Plug 'sindrets/diffview.nvim', { 'on': ['DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewFocusFiles', 'DiffviewToggleFiles', 'DiffviewRefresh'] }
" Plug 'sphamba/smear-cursor.nvim'
Plug 'mfussenegger/nvim-dap', { 'on': [] }
Plug 'rcarriga/nvim-dap-ui', { 'on': [] }
Plug 'nvim-neotest/nvim-nio', { 'on': [] }
Plug 'theHamsta/nvim-dap-virtual-text', { 'on': [] }
Plug 'nvim-neotest/neotest', { 'on': [] }
Plug 'nvim-neotest/neotest-python', { 'on': [] }
Plug 'nvim-neotest/neotest-jest', { 'on': [] }
Plug 'fredrikaverpil/neotest-golang', { 'on': [] }

Plug 'folke/snacks.nvim'

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
nnoremap <leader>fF <cmd>FzfLua files<cr>
nnoremap <leader>fG <cmd>FzfLua live_grep<cr>
nnoremap <leader>fB <cmd>FzfLua buffers<cr>
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
" ===========================================================================
" 4. COC & COPILOT LOGIC
" ============================================================================
let g:coc_global_extensions = ['coc-pyright', 'coc-tsserver', 'coc-json', 'coc-html', 'coc-css', 'coc-prettier', 'coc-vimlsp', 'coc-snippets', 'coc-eslint', '@yaegassy/coc-ruff', 'coc-clangd', 'coc-go']
let g:copilot_no_tab_map = v:true

inoremap <silent><expr> <TAB>
      \ copilot#Accept("\<CR>") !=# "\<CR>" ? copilot#Accept("\<TAB>") :
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ CocSnippetExpandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! CocSnippetExpandableOrJumpable() abort
  try
    return coc#expandableOrJumpable()
  catch /^Vim\%((\a\+)\)\=:E605/
    return v:false
  catch /coc-snippets not registered/
    return v:false
  endtry
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
" 6. BUFFERLINE SETTINGS & KEYBINDINGS
" ============================================================================
nnoremap <silent> <leader>bp :BufferLineTogglePin<CR>
nnoremap <silent> <Tab> :BufferLineCycleNext<CR>
nnoremap <silent> <S-Tab> :BufferLineCyclePrev<CR>
nnoremap <silent> <leader>bc :bdelete<CR>
nnoremap <silent> <leader>be :BufferLineMoveNext<CR>
nnoremap <silent> <leader>bq :BufferLineMovePrev<CR>
" ============================================================================
" 8. LUA CONFIGURATIONS
" ============================================================================
lua << EOF

local config_home = vim.g.nvim_config_home or vim.fn.stdpath("config")
local config_lua = config_home .. "/lua/?.lua"
local config_lua_init = config_home .. "/lua/?/init.lua"
if not package.path:find(config_lua, 1, true) then
    package.path = config_lua .. ";" .. config_lua_init .. ";" .. package.path
end

local M = require("helper.utils")

local catppuccin = M.safe_require("catppuccin")
if catppuccin then
    catppuccin.setup({
        transparent_background = true,
    })
end

local lualine = M.safe_require("lualine")
if lualine then
    lualine.setup({
        options = {
            globalstatus = true,
        },
        sections = {
            lualine_c = {
                { "filename", path = 1 },
                {
                    "diagnostics",
                    sources = { "nvim_diagnostic" },
                    symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
                },
            },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = {
                { "location" },
            },
        },
        extensions = {
            "fugitive",
            "neo-tree",
            "quickfix",
            "toggleterm",
            "trouble",
        },
        inactive_sections = {
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "location" },
        },
    })
end

local function setup_coc_diagnostic_bridge()
    if vim.fn.exists("*CocAction") == 0 then
        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("CocDiagnosticBridgeBootstrap", { clear = true }),
            pattern = "CocNvimInit",
            callback = setup_coc_diagnostic_bridge,
            once = true,
        })
        return
    end

    vim.diagnostic.config({
        virtual_text = false,
        signs = false,
        underline = false,
        update_in_insert = false,
    })

    local namespace = vim.api.nvim_create_namespace("coc_bridge")
    local severity_map = {
        Error = vim.diagnostic.severity.ERROR,
        Warning = vim.diagnostic.severity.WARN,
        Information = vim.diagnostic.severity.INFO,
        Hint = vim.diagnostic.severity.HINT,
    }

    local function publish()
        local ok_diagnostics, coc_diagnostics = pcall(vim.fn.CocAction, "diagnosticList")
        if not ok_diagnostics or type(coc_diagnostics) ~= "table" then
            return
        end

        local by_buf = {}
        for _, item in ipairs(coc_diagnostics) do
            local file = item.file or item.uri
            local bufnr = file and vim.fn.bufnr(file)

            if bufnr and bufnr > 0 and vim.api.nvim_buf_is_loaded(bufnr) then
                by_buf[bufnr] = by_buf[bufnr] or {}

                local lnum = tonumber(item.lnum or item.line or item.range and item.range.start and item.range.start.line) or 1
                local col = tonumber(item.col or item.character or item.range and item.range.start and item.range.start.character) or 1

                table.insert(by_buf[bufnr], {
                    lnum = math.max(lnum - 1, 0),
                    col = math.max(col - 1, 0),
                    end_lnum = math.max(lnum - 1, 0),
                    end_col = math.max(col, 0),
                    severity = severity_map[item.severity] or vim.diagnostic.severity.INFO,
                    message = item.message or "",
                    source = item.source or "coc",
                })
            end
        end

        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
                vim.diagnostic.set(namespace, bufnr, by_buf[bufnr] or {})
            end
        end
    end

    local group = vim.api.nvim_create_augroup("CocDiagnosticBridge", { clear = true })

    local pending_publish = false
    local function schedule_publish()
        if pending_publish then
            return
        end
        pending_publish = true
        vim.defer_fn(function()
            pending_publish = false
            publish()
        end, 100)
    end

    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "CocDiagnosticChange",
        callback = schedule_publish,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        callback = schedule_publish,
    })

    vim.defer_fn(publish, 500)
end

setup_coc_diagnostic_bridge()

--[[
local ok, smear = pcall(require, "smear_cursor")

if ok then
    smear.setup({
        smear_between_buffers = true,
        smear_between_neighbor_lines = true,
        scroll_buffer_space = true,
        legacy_computing_symbols_support = false,

        smear_insert_mode = false,
        cursor_color = "#b48ead",
        particles_enabled = true,
        stiffness = 0.5,
        trailing_stiffness = 0.2,
        trailing_exponent = 5,
        damping = 0.6,
        gradient_exponent = 0,
        gamma = 1,
        never_draw_over_target = true,
        hide_target_hack = true,
        particle_spread = 1,
        particles_per_second = 500,
        particles_per_length = 50,
        particle_max_lifetime = 800,
        particle_max_initial_velocity = 20,
        particle_velocity_from_cursor = 0.5,
        particle_damping = 0.15,
        particle_gravity = -50,
        min_distance_emit_particles = 0,
        time_interval = 7,
    })

    local group = vim.api.nvim_create_augroup("SmearInsertMode", { clear = true })

    local function disable_smear_effects()
        smear.enabled = false
    end

    local function enable_smear_effects()
        smear.enabled = true
    end

    vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
        group = group,
        callback = disable_smear_effects,
    })

    vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
        group = group,
        callback = enable_smear_effects,
    })
end
]]


EOF

colorscheme tokyonight-night 
