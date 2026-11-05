-- nvim --headless -u NONE -i NONE -l tests/upgrades.lua
local config_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(config_root)
vim.o.swapfile = false
vim.o.hidden = true
vim.o.termguicolors = true
vim.g.mapleader = " "
local original_cwd = vim.fn.getcwd()
local fixture = vim.fn.tempname() .. "-nvim-upgrades"
assert(not vim.uv.fs_stat(fixture))
vim.fn.mkdir(fixture, "p")
local fixture_real = assert(vim.uv.fs_realpath(fixture))
fixture = fixture_real
local passed = 0
local function check(name, fn)
    fn()
    passed = passed + 1
    print("PASS " .. name)
end
local function equal(actual, expected)
    assert(vim.deep_equal(actual, expected), vim.inspect({ actual = actual, expected = expected }))
end
local function buffer(name, lines)
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, name)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines or { "local value = 1" })
    return buf
end
local function key(specs, plugin, lhs, mode)
    for _, spec in ipairs(specs) do
        if spec[1] == plugin then
            for _, mapping in ipairs(spec.keys or {}) do
                if mapping[1] == lhs and (mapping.mode or "n") == (mode or "n") then
                    return mapping[2]
                end
            end
        end
    end
    error("Missing mapping " .. lhs)
end

local ok, err = xpcall(function()
    vim.fn.mkdir(fixture .. "/outside", "p")
    vim.fn.mkdir(fixture .. "/repo with spaces/src", "p")
    vim.fn.mkdir(fixture .. "/standalone/src", "p")
    vim.fn.writefile({ "gitdir: elsewhere" }, fixture .. "/repo with spaces/.git")
    vim.fn.writefile({ "{}" }, fixture .. "/repo with spaces/src/package.json")
    vim.fn.writefile({ "{}" }, fixture .. "/standalone/package.json")
    vim.api.nvim_set_current_dir(fixture .. "/outside")
    local project = require("helper.project")
    local buf = buffer(fixture .. "/repo with spaces/src/new.lua")
    local repo = vim.fs.normalize(fixture .. "/repo with spaces")
    check("Git worktree file, spaces, and monorepo root", function()
        equal(project.root(), repo)
        equal(project.directory(), repo .. "/src")
    end)
    check("new files in nonexistent directories", function()
        buffer(fixture .. "/repo with spaces/new/deep/file.lua")
        equal(project.root(), repo)
        equal(project.directory(), repo)
    end)
    check("language marker without Git", function()
        buffer(fixture .. "/standalone/src/main.js")
        equal(project.root(), vim.fs.normalize(fixture .. "/standalone"))
    end)
    check("unnamed, special, and markerless buffers fall back to cwd", function()
        vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true, false))
        equal(project.root(), vim.fn.getcwd())
        buffer("test://virtual/file")
        vim.bo.buftype = "nofile"
        equal(project.root(), vim.fn.getcwd())
        buffer(fixture .. "/outside/plain.txt")
        equal(project.root(), vim.fn.getcwd())
    end)
    vim.api.nvim_set_current_buf(buf)
    local format = require("helper.format")
    check("format defaults, Java, and machine/buffer overrides", function()
        equal(format.on_save(buf).timeout_ms, 1000)
        vim.bo.filetype = "java"
        equal(format.on_save(buf).timeout_ms, 3000)
        vim.g.autoformat_timeout_ms = 2000
        equal(format.on_save(buf).timeout_ms, 2000)
        vim.b.autoformat_timeout_ms = 750
        equal(format.on_save(buf).timeout_ms, 750)
        vim.b.autoformat_timeout_ms = -1
        equal(format.on_save(buf).timeout_ms, 3000)
        vim.b.autoformat_timeout_ms = nil
        vim.g.autoformat_timeout_ms = nil
        vim.bo.filetype = "lua"
    end)
    check("format disable flags and non-editable buffers", function()
        for _, flag in ipairs({ "disable_autoformat", "bigfile" }) do
            vim.b[flag] = true
            equal(format.on_save(buf), nil)
            vim.b[flag] = nil
        end
        vim.g.disable_autoformat = true
        equal(format.on_save(buf), nil)
        vim.g.disable_autoformat = nil
        vim.bo.modifiable = false
        equal(format.on_save(buf), nil)
        vim.bo.modifiable = true
        vim.bo.buftype = "nofile"
        equal(format.on_save(buf), nil)
        vim.bo.buftype = ""
    end)
    check("growing files and minified lines skip autoformat", function()
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep("x", 501) })
        equal(format.on_save(buf), nil)
        local lines = {}
        for i = 1, 11000 do
            lines[i] = string.rep("x", 100)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        equal(format.on_save(buf), nil)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "local value = 1" })
        assert(format.on_save(buf))
    end)

    local searches = require("plugins.search")
    check("search scopes are explicit and never change cwd", function()
        local calls = {}
        package.loaded["fzf-lua"] = setmetatable({}, {
            __index = function(_, provider)
                return function(opts)
                    calls[#calls + 1] = { provider, opts }
                end
            end,
        })
        local cwd = vim.fn.getcwd()
        for _, lhs in ipairs({ "ff", "fg", "fN", "fw" }) do
            key(searches, "ibhagwan/fzf-lua", "<leader>" .. lhs)()
            equal(calls[#calls][2].cwd, repo)
        end
        for _, lhs in ipairs({ "fF", "fG" }) do
            key(searches, "ibhagwan/fzf-lua", "<leader>" .. lhs)()
            equal(calls[#calls][2].cwd, cwd)
        end
        for _, lhs in ipairs({ "fe", "fE" }) do
            key(searches, "ibhagwan/fzf-lua", "<leader>" .. lhs)()
            equal(calls[#calls][2].cwd, repo .. "/src")
        end
        key(searches, "ibhagwan/fzf-lua", "<leader>fR")()
        equal(calls[#calls], { "resume", {} })
        key(searches, "ibhagwan/fzf-lua", "<leader>fw", "x")()
        equal(calls[#calls][1], "grep_visual")
        equal(vim.fn.getcwd(), cwd)
        package.loaded["fzf-lua"] = nil
    end)

    local plugin_root = vim.env.SUNGP_TEST_PLUGIN_ROOT or (vim.fn.stdpath("data") .. "/lazy")
    for _, plugin in ipairs({ "snacks.nvim", "hlchunk.nvim", "dropbar.nvim", "nvim-web-devicons" }) do
        local path = plugin_root .. "/" .. plugin
        assert(vim.fn.isdirectory(path) == 1, "Install locked plugins first: " .. path)
        vim.opt.runtimepath:append(path)
    end
    local snacks = require("snacks")
    snacks.setup({ scratch = { root = fixture .. "/scratch" } })
    local ui = require("plugins.ui")
    local hlchunk = require("hlchunk")
    local setup, hlchunk_opts = hlchunk.setup, nil
    hlchunk.setup = function(opts)
        hlchunk_opts = opts
        return setup(opts)
    end
    vim.loader.enable()
    require("integrations.hlchunk")
    hlchunk.setup = setup
    check("all hlchunk modules, Treesitter and chunk textobject", function()
        for _, name in ipairs({ "chunk", "indent" }) do
            assert(hlchunk_opts[name].enable, name)
            assert(hlchunk_opts[name].exclude_filetypes.bigfile, name .. " must exclude big files")
            assert(#vim.api.nvim_get_autocmds({ group = "hlchunk_" .. name }) > 0, name .. " did not enable")
        end
        assert(hlchunk_opts.chunk.use_treesitter)
        assert(not hlchunk_opts.indent.use_treesitter)
        assert(#vim.api.nvim_get_autocmds({ group = "hlchunk_blank" }) > 0)
        assert(#vim.api.nvim_get_autocmds({ group = "hlchunk_line_num" }) > 0, "line numbers did not enable")
        assert(hlchunk_opts.chunk.delay == 0, "unstable animation must remain disabled")
        assert(vim.fn.maparg("iH", "o", false, true).callback)
        assert(vim.fn.maparg("iH", "x", false, true).callback)
        vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
        local python = buffer(
            fixture .. "/chunk.py",
            { "def example():", "    if True:", "        print('hello')", "    return 1" }
        )
        vim.bo.filetype = "python"
        vim.bo.shiftwidth = 4
        vim.treesitter.start(python, "python")
        vim.treesitter.get_parser(python):parse()
        local helper = require("hlchunk.utils.chunkHelper")
        local code, range =
            helper.get_chunk_range({ pos = { bufnr = python, row = 2, col = 10 }, use_treesitter = true })
        assert(code == helper.CHUNK_RANGE_RET.OK, "Python block was not found")
        assert(range.start == 1 and range.finish == 2, "wrong Python if-block range")
        vim.api.nvim_win_set_cursor(0, { 3, 10 })
        vim.fn.maparg("iH", "x", false, true).callback()
        assert(vim.api.nvim_get_mode().mode == "V", "chunk textobject did not select lines")
        vim.cmd("normal! \27")
    end)

    check("hlchunk renders guides and reuses unchanged line-number marks", function()
        local buf = buffer(fixture .. "/guides.py", {
            "def example():",
            "    value = 1",
            "",
            "    return value",
            "",
            "def other():",
            "    return 2",
        })
        vim.bo.filetype = "python"
        vim.bo.shiftwidth = 4
        vim.treesitter.start(buf, "python")
        vim.treesitter.get_parser(buf):parse()
        vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = buf })
        vim.wait(250)
        local namespaces = vim.api.nvim_get_namespaces()
        local function marks(name)
            return vim.api.nvim_buf_get_extmarks(buf, namespaces[name], 0, -1, {})
        end
        assert(#marks("indent") > 0, "indent guides did not render")
        local blanks = marks("blank")
        assert(#blanks > 0, "blank guides did not render")
        for _, mark in ipairs(blanks) do
            assert(vim.api.nvim_buf_get_lines(buf, mark[2], mark[2] + 1, false)[1]:match("^%s*$"))
        end
        local function move(row)
            vim.api.nvim_win_set_cursor(0, { row, 4 })
            vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf, group = "hlchunk_line_num" })
        end
        move(2)
        local before = marks("line_num")
        assert(#before > 0, "line numbers did not render")
        move(4)
        equal(marks("line_num"), before)
        move(7)
        assert(not vim.deep_equal(marks("line_num"), before), "new block reused stale marks")
        vim.cmd("DisableHLLineNum")
        equal(marks("line_num"), {})
        vim.cmd("EnableHLLineNum")
        move(2)
        assert(#marks("line_num") > 0)
        vim.bo.filetype = "bigfile"
        move(4)
        equal(marks("line_num"), {})
    end)

    check("hlchunk scroll caches stay separate and bigfile clears every module", function()
        require("config.autocmds")
        local lines = { "def example():" }
        for i = 2, 300 do
            lines[i] = i % 2 == 0 and "    value = 1" or ""
        end
        local buf = buffer(fixture .. "/scroll.py", lines)
        vim.bo.filetype = "python"
        vim.bo.shiftwidth = 4
        vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = buf })
        vim.wait(250)
        local namespaces = vim.api.nvim_get_namespaces()
        local function marks(name, row)
            return vim.api.nvim_buf_get_extmarks(
                buf,
                namespaces[name],
                row and { row, 0 } or 0,
                row and { row, 100 } or -1,
                {}
            )
        end
        local function scroll(row)
            vim.api.nvim_win_set_cursor(0, { row, 4 })
            vim.cmd("normal! zt")
            vim.api.nvim_exec_autocmds("User", { pattern = "WinScrolledY" })
            vim.wait(250)
            assert(#marks("indent", row - 1) == 1, "indent missing or duplicated after scroll")
            assert(#marks("blank", row) == 1, "blank missing or duplicated after scroll")
        end
        scroll(180)
        scroll(40)
        scroll(180)
        vim.cmd("DisableHLIndent")
        equal(marks("indent"), {})
        assert(#marks("blank", 180) == 1, "indent toggle cleared blank guides")
        vim.cmd("EnableHLIndent")
        vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = buf })
        vim.wait(250)
        assert(#marks("indent", 179) == 1 and #marks("blank", 180) == 1)
        -- Include all namespaces so cleanup is tested even without a parser.
        for _, name in ipairs({ "chunk", "line_num" }) do
            vim.api.nvim_buf_set_extmark(buf, namespaces[name], 0, 0, {})
        end
        vim.api.nvim_buf_set_lines(buf, 20, 21, false, { string.rep("x", 50000) })
        vim.api.nvim_exec_autocmds("TextChanged", { buffer = buf })
        assert(vim.b.bigfile)
        vim.wait(250)
        for _, name in ipairs({ "chunk", "indent", "blank", "line_num" }) do
            equal(marks(name), {})
        end
        buffer(fixture .. "/after-scroll.lua", { "local value = 1" })
        vim.bo.filetype = "lua"
    end)

    check("UI toggles can be repeatedly disabled and enabled", function()
        for _, spec in ipairs(ui) do
            for _, mapping in ipairs(spec.keys or {}) do
                if mapping[1]:match("^<leader>u") and type(mapping[2]) == "function" then
                    vim.keymap.set("n", mapping[1], mapping[2])
                end
            end
        end
        for _, lhs in ipairs({ "ui", "uc" }) do
            local action = key(ui, "shellRaining/hlchunk.nvim", "<leader>" .. lhs)
            action()
            action()
            action()
            action()
        end
        for _, lhs in ipairs({ "uw", "ud", "uf", "uF" }) do
            local action = key(ui, "folke/snacks.nvim", "<leader>" .. lhs)
            action()
            action()
        end
    end)
    check("breadcrumbs preserve other window bars and honor bigfile", function()
        local dropbar = require("integrations.dropbar")
        assert(vim.wo.winbar:find("dropbar", 1, true))
        dropbar.toggle()
        equal(vim.wo.winbar, "")
        dropbar.toggle()
        assert(vim.wo.winbar:find("dropbar", 1, true))
        vim.wo.winbar = "custom bar"
        dropbar.toggle()
        equal(vim.wo.winbar, "custom bar")
        dropbar.toggle()
        equal(vim.wo.winbar, "custom bar")
        vim.wo.winbar = ""
        vim.b.bigfile = true
        dropbar.toggle()
        dropbar.toggle()
        equal(vim.wo.winbar, "")
        vim.b.bigfile = nil
    end)
    check("Zen and zoom restore window layout", function()
        local before = { vim.o.laststatus, vim.o.showtabline, vim.api.nvim_get_current_win() }
        for _, lhs in ipairs({ "uz", "uZ" }) do
            local action = key(ui, "folke/snacks.nvim", "<leader>" .. lhs)
            action()
            vim.wait(50)
            assert(snacks.zen.win and snacks.zen.win:valid())
            action()
            vim.wait(50)
            equal({ vim.o.laststatus, vim.o.showtabline, vim.api.nvim_get_current_win() }, before)
        end
    end)
    check("scratch writes only to isolated data", function()
        key(ui, "folke/snacks.nvim", "<leader>u.")()
        local name = vim.api.nvim_buf_get_name(0)
        assert(vim.fs.normalize(name):find(vim.fs.normalize(fixture .. "/scratch/"), 1, true) == 1)
        equal(vim.bo.filetype, "markdown")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "test note" })
        key(ui, "folke/snacks.nvim", "<leader>u.")()
        assert(vim.wait(1000, function()
            return vim.fn.filereadable(name) == 1
        end))
        equal(vim.fn.readfile(name), { "test note" })
    end)
    check("runtime profiler starts and stops", function()
        snacks.profiler.start()
        assert(snacks.profiler.running())
        project.root()
        snacks.profiler.stop({ pick = false, highlights = false })
        assert(not snacks.profiler.running())
    end)
end, debug.traceback)

vim.api.nvim_set_current_dir(original_cwd)
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
end
assert(vim.uv.fs_realpath(fixture) == fixture_real, "fixture path changed")
assert(fixture:match("%-nvim%-upgrades$"), "unsafe cleanup path")
vim.fn.delete(fixture, "rf")
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd.cquit()
end
print(("%d upgrade checks passed"):format(passed))
vim.cmd.qa({ bang = true })
