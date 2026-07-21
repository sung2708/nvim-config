local M = require("helper.utils")

local parser_install_dir = vim.fn.stdpath("data") .. "/site"
local config_dir = vim.fn.stdpath("config")

local function is_executable(command)
    return vim.fn.executable(command) == 1
end

local function first_executable(commands)
    for _, command in ipairs(commands) do
        if is_executable(command) then
            return command
        end
    end
end

if vim.fn.has("win32") == 1 then
    local zig_cc = config_dir .. "/bin/zig-cc.cmd"
    local zig_cxx = config_dir .. "/bin/zig-cxx.cmd"

    if not vim.env.CC and is_executable(zig_cc) then
        vim.env.CC = zig_cc
    end
    if not vim.env.CXX and is_executable(zig_cxx) then
        vim.env.CXX = zig_cxx
    end
else
    vim.env.CC = vim.env.CC or first_executable({ "cc", "clang", "gcc", "zig" })
    vim.env.CXX = vim.env.CXX or first_executable({ "c++", "clang++", "g++", "zig" })
end

local legacy_install = M.safe_require("nvim-treesitter.install")
if legacy_install then
    if vim.fn.has("win32") == 1 then
        legacy_install.compilers = { "zig", "clang", "gcc", "cl", "cc" }
    else
        legacy_install.compilers = { "cc", "clang", "gcc", "zig" }
    end
end

local ok_new, new_treesitter = pcall(require, "nvim-treesitter")
if ok_new then
    new_treesitter.setup({
        install_dir = parser_install_dir,
    })

    vim.opt.runtimepath:prepend(parser_install_dir)

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
        callback = function(args)
            pcall(vim.treesitter.start, args.buf)
        end,
    })
else
    local legacy_treesitter = M.safe_require("nvim-treesitter.configs")
    if legacy_treesitter then
        legacy_treesitter.setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
        })
    end
end

local ok_textobjects, textobjects = pcall(require, "nvim-treesitter-textobjects")
if ok_textobjects then
    textobjects.setup({
        select = {
            lookahead = true,
            selection_modes = {
                ["@parameter.outer"] = "v",
                ["@function.outer"] = "V",
            },
            include_surrounding_whitespace = false,
        },
        move = {
            set_jumps = true,
        },
    })
end

local function ts_textobject(module, method, ...)
    local ok, mod = pcall(require, module)
    if ok and mod[method] then
        return mod[method](...)
    end
end

vim.keymap.set({ "x", "o" }, "am", function()
    ts_textobject("nvim-treesitter-textobjects.select", "select_textobject", "@function.outer", "textobjects")
end, { desc = "Select Around Function" })

vim.keymap.set({ "x", "o" }, "im", function()
    ts_textobject("nvim-treesitter-textobjects.select", "select_textobject", "@function.inner", "textobjects")
end, { desc = "Select Inside Function" })

vim.keymap.set({ "x", "o" }, "ac", function()
    ts_textobject("nvim-treesitter-textobjects.select", "select_textobject", "@class.outer", "textobjects")
end, { desc = "Select Around Class" })

vim.keymap.set({ "x", "o" }, "ic", function()
    ts_textobject("nvim-treesitter-textobjects.select", "select_textobject", "@class.inner", "textobjects")
end, { desc = "Select Inside Class" })

vim.keymap.set({ "x", "o" }, "as", function()
    ts_textobject("nvim-treesitter-textobjects.select", "select_textobject", "@local.scope", "locals")
end, { desc = "Select Around Scope" })

vim.keymap.set("n", "<leader>a", function()
    ts_textobject("nvim-treesitter-textobjects.swap", "swap_next", "@parameter.inner")
end, { desc = "Swap Next Parameter" })

vim.keymap.set("n", "<leader>A", function()
    ts_textobject("nvim-treesitter-textobjects.swap", "swap_previous", "@parameter.outer")
end, { desc = "Swap Previous Parameter" })

vim.keymap.set({ "n", "x", "o" }, "]m", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_start", "@function.outer", "textobjects")
end, { desc = "Next Function Start" })

vim.keymap.set({ "n", "x", "o" }, "]]", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_start", "@class.outer", "textobjects")
end, { desc = "Next Class Start" })

vim.keymap.set({ "n", "x", "o" }, "]o", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_start", { "@loop.inner", "@loop.outer" }, "textobjects")
end, { desc = "Next Loop Start" })

vim.keymap.set({ "n", "x", "o" }, "]s", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_start", "@local.scope", "locals")
end, { desc = "Next Scope Start" })

vim.keymap.set({ "n", "x", "o" }, "]z", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_start", "@fold", "folds")
end, { desc = "Next Fold Start" })

vim.keymap.set({ "n", "x", "o" }, "]M", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_end", "@function.outer", "textobjects")
end, { desc = "Next Function End" })

vim.keymap.set({ "n", "x", "o" }, "][", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_end", "@class.outer", "textobjects")
end, { desc = "Next Class End" })

vim.keymap.set({ "n", "x", "o" }, "[m", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_previous_start", "@function.outer", "textobjects")
end, { desc = "Previous Function Start" })

vim.keymap.set({ "n", "x", "o" }, "[[", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_previous_start", "@class.outer", "textobjects")
end, { desc = "Previous Class Start" })

vim.keymap.set({ "n", "x", "o" }, "[M", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_previous_end", "@function.outer", "textobjects")
end, { desc = "Previous Function End" })

vim.keymap.set({ "n", "x", "o" }, "[]", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_previous_end", "@class.outer", "textobjects")
end, { desc = "Previous Class End" })

vim.keymap.set({ "n", "x", "o" }, "]C", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next", "@conditional.outer", "textobjects")
end, { desc = "Next Conditional" })

vim.keymap.set({ "n", "x", "o" }, "[C", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_previous", "@conditional.outer", "textobjects")
end, { desc = "Previous Conditional" })
