local opt = vim.opt

-- This configuration does not use the legacy Node, Perl, or Ruby remote
-- providers. Disabling them avoids platform-specific health warnings and
-- does not affect regular Lua plugins or external formatters/LSP servers.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Neovim 0.12 supplies modern Lua mappings for Markdown headings. Disable the
-- older Vimscript duplicates so lazy.nvim can replay FileType safely without
-- leaving E31 ("No such mapping") in v:errmsg.
vim.g.no_markdown_maps = 1

local path_separator = vim.fn.has("win32") == 1 and ";" or ":"

local function prepend_path(directory)
    if directory and vim.fn.isdirectory(directory) == 1 then
        local path_entries = vim.split(vim.env.PATH or "", path_separator, { plain = true, trimempty = true })
        if not vim.tbl_contains(path_entries, directory) then
            vim.env.PATH = directory .. path_separator .. vim.env.PATH
        end
    end
end

-- Mason owns the configured LSP/formatter/linter executables. Put its bin
-- directory on PATH before any lazy plugin event so first-save formatting and
-- linting work even when Mason's UI plugin has not been loaded yet.
prepend_path(vim.fn.stdpath("data") .. "/mason/bin")

for _, directory in ipairs({ vim.env.UV_PYTHON_BIN_DIR, vim.env.UV_TOOL_BIN_DIR }) do
    prepend_path(directory)
end

if vim.fn.has("win32") == 1 then
    local scoop_home = vim.env.SCOOP or vim.fn.expand("~/scoop")
    prepend_path(scoop_home .. "/apps/go/current/bin")
    prepend_path(scoop_home .. "/apps/maven/current/bin")
    prepend_path(scoop_home .. "/apps/imagemagick/current")

    -- Volta exposes tree-sitter through a shim that fails when nvim-treesitter
    -- runs it from a downloaded grammar project. Prefer the real executable.
    local volta_tree_sitter = vim.env.LOCALAPPDATA
        and vim.env.LOCALAPPDATA .. "/Volta/tools/image/packages/tree-sitter-cli"
    if volta_tree_sitter and vim.fn.isdirectory(volta_tree_sitter) == 1 then
        prepend_path(volta_tree_sitter)
    end

    local python_provider = vim.fn.stdpath("data") .. "/python-provider/Scripts/python.exe"
    if vim.fn.filereadable(python_provider) == 1 then
        vim.g.python3_host_prog = python_provider
    end

    local scoop_jdk = scoop_home .. "/apps/temurin21-jdk/current"
    if vim.fn.isdirectory(scoop_jdk) == 1 then
        vim.env.JAVA_HOME = vim.env.JAVA_HOME or scoop_jdk
        prepend_path(scoop_jdk .. "/bin")
    end
end

local machine = vim.uv.os_uname().machine:lower()
if vim.fn.has("win32") == 1 and not vim.env.GOARCH and (machine == "x86_64" or machine == "amd64") then
    vim.env.GOARCH = "amd64"
end

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.cursorcolumn = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.laststatus = 3
opt.scrolloff = 4
opt.sidescrolloff = 4
opt.list = false
opt.mouse = "a"

opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smarttab = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.encoding = "utf-8"
opt.hidden = true
opt.updatetime = 400
opt.timeoutlen = 600
opt.ttimeoutlen = 10
opt.redrawtime = 1500
opt.synmaxcol = 400
opt.confirm = true
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.winblend = 12
opt.pumblend = 12

if vim.fn.has("win32") == 1 then
    opt.clipboard = "unnamed"
else
    opt.clipboard = "unnamedplus"
end

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

opt.foldlevel = 99
opt.foldmethod = "manual"
