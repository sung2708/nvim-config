require("config.compiler")
local required_parsers = require("config.parsers")

local function is_executable(command)
    return vim.fn.executable(command) == 1
end

local new_treesitter = require("nvim-treesitter")
new_treesitter.setup()

local installed = {}
for _, parser in ipairs(new_treesitter.get_installed("parsers")) do
    installed[parser] = true
end

local missing = vim.tbl_filter(function(parser)
    return not installed[parser]
end, required_parsers)

if #missing > 0 and not is_executable("tree-sitter") then
    vim.schedule(function()
        vim.notify(
            "Treesitter: missing tree-sitter CLI. Install tree-sitter-cli (macOS: brew install tree-sitter-cli), then restart Neovim.",
            vim.log.levels.WARN
        )
    end)
elseif #missing > 0 then
    vim.defer_fn(function()
        new_treesitter.install(missing, { force = true, max_jobs = 4 }):await(function(err, success)
            vim.schedule(function()
                if err or success == false then
                    vim.notify(
                        "Treesitter parser installation failed: " .. tostring(err or "see :TSLog"),
                        vim.log.levels.ERROR
                    )
                    return
                end

                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    if
                        vim.api.nvim_buf_is_loaded(bufnr)
                        and vim.bo[bufnr].filetype ~= ""
                        and vim.bo[bufnr].filetype ~= "bigfile"
                        and vim.bo[bufnr].buftype == ""
                        and not vim.b[bufnr].bigfile
                        and vim.fn.bufwinid(bufnr) ~= -1
                    then
                        pcall(vim.treesitter.start, bufnr)
                    end
                end
            end)
        end)
    end, 200)
end

local function start_treesitter(bufnr)
    if
        vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_is_loaded(bufnr)
        and vim.bo[bufnr].buftype == ""
        and vim.bo[bufnr].filetype ~= ""
        and vim.bo[bufnr].filetype ~= "bigfile"
        and not vim.b[bufnr].bigfile
    then
        pcall(vim.treesitter.start, bufnr)
    end
end

local pending = {}
local function schedule_treesitter(bufnr, delay)
    local timer = pending[bufnr]
    if timer and not timer:is_closing() then
        timer:stop()
        timer:close()
    end

    pending[bufnr] = vim.defer_fn(function()
        pending[bufnr] = nil
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.fn.bufwinid(bufnr) == -1 then
            return
        end
        start_treesitter(bufnr)
    end, delay)
end

local treesitter_group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true })
vim.api.nvim_create_autocmd("BufWipeout", {
    group = treesitter_group,
    callback = function(args)
        local timer = pending[args.buf]
        pending[args.buf] = nil
        if timer and not timer:is_closing() then
            timer:stop()
            timer:close()
        end
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = treesitter_group,
    callback = function(args)
        -- BufWinEnter below normally replaces this fallback. Keeping a
        -- longer FileType timer also covers :setfiletype on an open buffer.
        schedule_treesitter(args.buf, 1000)
    end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = treesitter_group,
    callback = function(args)
        schedule_treesitter(args.buf, 20)
    end,
})

if vim.bo.filetype ~= "" then
    -- When the plugin itself was deferred until after VimEnter, the first
    -- buffer is already visible; start highlighting shortly afterwards.
    schedule_treesitter(vim.api.nvim_get_current_buf(), 40)
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

vim.keymap.set("n", "<leader>mp", function()
    ts_textobject("nvim-treesitter-textobjects.swap", "swap_next", "@parameter.inner")
end, { desc = "Swap Next Parameter" })

vim.keymap.set("n", "<leader>mP", function()
    ts_textobject("nvim-treesitter-textobjects.swap", "swap_previous", "@parameter.inner")
end, { desc = "Swap Previous Parameter" })

vim.keymap.set({ "n", "x", "o" }, "]m", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_start", "@function.outer", "textobjects")
end, { desc = "Next Function Start" })

vim.keymap.set({ "n", "x", "o" }, "]]", function()
    ts_textobject("nvim-treesitter-textobjects.move", "goto_next_start", "@class.outer", "textobjects")
end, { desc = "Next Class Start" })

vim.keymap.set({ "n", "x", "o" }, "]o", function()
    ts_textobject(
        "nvim-treesitter-textobjects.move",
        "goto_next_start",
        { "@loop.inner", "@loop.outer" },
        "textobjects"
    )
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
