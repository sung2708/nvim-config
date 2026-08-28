-- Run from the config directory: nvim --headless -u NONE -i NONE -l tests/dashboard_pick.lua
local config_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local test_parent = vim.fs.normalize(config_root .. "/.nvim-data")
local test_root = test_parent .. "/dashboard-pick-test-" .. vim.fn.getpid()
assert(not vim.uv.fs_stat(test_root), "test fixture directory already exists")
vim.fn.mkdir(test_root, "p")
vim.opt.runtimepath:prepend(config_root)
vim.o.directory = test_root .. "//"
vim.o.updatecount = 200
vim.o.swapfile = true
vim.o.hidden = true

local pick, picker_opts, active_window, state
local entries, jobs = {}, {}
local passed = 0

package.loaded["snacks"] = {
    setup = function(opts)
        pick = opts.dashboard.preset.pick
    end,
}
package.loaded["fzf-lua"] = {
    files = function(opts)
        picker_opts = opts
    end,
}
package.loaded["fzf-lua.path"] = {
    entry_to_file = function(selected)
        return assert(entries[selected])
    end,
    is_absolute = function(path)
        return path:match("^%a:[/\\]") or path:sub(1, 1) == "/"
    end,
    join = function(paths)
        return table.concat(paths, "/")
    end,
    normalize = vim.fs.normalize,
}
package.loaded["fzf-lua.utils"] = {
    cwd = function()
        return test_root
    end,
    fzf_winobj = function()
        return active_window
    end,
    clear_CTX = function()
        assert(active_window == nil, "picker context cleared before closing")
        state.cleared = state.cleared + 1
    end,
}
package.loaded["fzf-lua.actions"] = {
    file_edit_or_qf = function(selected, opts)
        assert(active_window == nil, "fallback ran before closing the picker")
        state.fallback = { selected = selected, opts = opts }
        if state.fallback_error then
            error(state.fallback_error)
        end
    end,
}
require("integrations.snacks")

local function setup_picker()
    vim.cmd.enew({ bang = true })
    local source_win = vim.api.nvim_get_current_win()
    local source_buf = vim.api.nvim_get_current_buf()
    vim.bo[source_buf].buftype = "nofile"
    vim.bo[source_buf].bufhidden = "wipe"
    vim.bo[source_buf].filetype = "snacks_dashboard"
    vim.bo[source_buf].swapfile = false
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "dashboard" })
    vim.bo[source_buf].modified = false

    local float_buf = vim.api.nvim_create_buf(false, true)
    local float = vim.api.nvim_open_win(float_buf, true, {
        relative = "editor", row = 2, col = 2, width = 20, height = 5,
    })
    state = { closed = 0, cleared = 0, source_win = source_win, source_buf = source_buf }
    active_window = {
        src_winid = source_win,
        close = function()
            state.closed = state.closed + 1
            state.buffer_at_close = vim.api.nvim_win_get_buf(source_win)
            vim.api.nvim_win_close(float, true)
            vim.api.nvim_buf_delete(float_buf, { force = true })
            active_window = nil
        end,
    }
    pick("files", { cwd = test_root })
    assert(picker_opts.actions.enter.noclose, "picker must remain visible while opening")
end

local function select_entries(selected)
    picker_opts.actions.enter.fn(selected, picker_opts)
    assert(state.closed == 1, "picker must close exactly once")
    assert(state.cleared == 1, "picker context was not cleared")
end

local function check(name, fn)
    fn()
    passed = passed + 1
    print("PASS " .. name)
end

local function stale_swap(name)
    local file = test_root .. "/" .. name .. ".txt"
    vim.fn.writefile({ "disk contents", "second line" }, file)
    local job = vim.fn.jobstart({ vim.v.progpath, "--embed", "--headless", "-u", "NONE", "-i", "NONE" }, { rpc = true })
    assert(job > 0, "failed to start swap fixture process")
    jobs[#jobs + 1] = job
    local swap = vim.rpcrequest(job, "nvim_exec_lua", [[
        local root, file = ...
        vim.o.directory = root .. "//"
        vim.cmd.edit(file)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "recovered contents", "unsaved second line" })
        vim.cmd.preserve()
        return vim.fn.swapname(0)
    ]], { test_root, file })
    -- Retain a fixture swap across a clean exit, without killing any user session.
    local retained = swap .. ".retained"
    assert(vim.uv.fs_copyfile(swap, retained))
    vim.rpcnotify(job, "nvim_command", "qa!")
    assert(vim.fn.jobwait({ job }, 3000)[1] == 0, "swap fixture process did not exit")
    assert(vim.uv.fs_copyfile(retained, swap))
    return file, swap
end

local ok, err = xpcall(function()
    check("normal open completes before the picker closes", function()
        local path = "file with spaces [#%].txt"
        vim.fn.writefile({ "first line", "second line" }, test_root .. "/" .. path)
        setup_picker()
        entries.file = { path = path }
        select_entries({ "file" })
        local bufnr = vim.fn.bufnr(test_root .. "/" .. path)
        assert(state.buffer_at_close == bufnr)
        assert(vim.api.nvim_get_current_buf() == bufnr)
        assert(vim.bo[bufnr].buflisted)
    end)

    check("existing buffers retain unsaved contents and search positions", function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(bufnr, 1, 2, false, { "unsaved line" })
        setup_picker()
        entries.buffer = { bufnr = bufnr, line = 2, col = 4 }
        select_entries({ "buffer" })
        assert(vim.api.nvim_get_current_buf() == bufnr)
        assert(vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1] == "unsaved line")
        assert(vim.bo[bufnr].modified)
        assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 2, 3 }))
    end)

    for _, choice in ipairs({ "r", "q", "o", "e", "a" }) do
        check("stale swap choice " .. choice, function()
            local file, swap = stale_swap("swap-" .. choice)
            local original_swap = vim.fn.readfile(swap, "b")
            setup_picker()
            entries.swap = { path = file, line = 2, col = 2 }
            local seen = 0
            local autocmd = vim.api.nvim_create_autocmd("SwapExists", {
                callback = function()
                    seen = seen + 1
                    vim.v.swapchoice = choice
                end,
            })
            local selected_ok, selected_err = pcall(select_entries, { "swap" })
            vim.api.nvim_del_autocmd(autocmd)
            assert(selected_ok, selected_err)
            assert(seen == 1, "native swap handler was bypassed")
            assert(vim.deep_equal(original_swap, vim.fn.readfile(swap, "b")), "original swap was changed")
            assert(
                vim.deep_equal(vim.fn.readfile(file), { "disk contents", "second line" }),
                "original file was changed"
            )
            local target = vim.fn.bufnr(file)
            if choice == "q" or choice == "a" then
                assert(vim.api.nvim_win_get_buf(state.source_win) ~= target)
                assert(not vim.api.nvim_buf_is_loaded(target))
            else
                assert(state.buffer_at_close == target)
                local first_line = vim.api.nvim_buf_get_lines(target, 0, 1, false)[1]
                assert(first_line == (choice == "r" and "recovered contents" or "disk contents"))
                assert(vim.bo[target].readonly == (choice == "o"))
                assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 2, 1 }))
            end
        end)
    end

    check("interactive E325 results still finish the selected action", function()
        local bufnr = vim.fn.bufnr(test_root .. "/file with spaces [#%].txt")
        setup_picker()
        entries.buffer = { bufnr = bufnr, line = 2, col = 4 }
        local buffer_command = vim.cmd.buffer
        -- A UI prompt reports E325 after applying the choice; SwapExists hooks do not.
        vim.cmd.buffer = function(target)
            buffer_command(target)
            error("Vim:E325: ATTENTION", 0)
        end
        local selected_ok, selected_err = pcall(select_entries, { "buffer" })
        vim.cmd.buffer = buffer_command
        assert(selected_ok, selected_err)
        assert(state.buffer_at_close == bufnr)
        assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 2, 3 }))
    end)

    check("buffer-open errors other than E325 still propagate", function()
        setup_picker()
        entries.invalid = { bufnr = vim.fn.bufnr(test_root .. "/file with spaces [#%].txt") }
        local buffer_command = vim.cmd.buffer
        vim.cmd.buffer = function()
            error("Vim:E37: No write since last change", 0)
        end
        local selected_ok, selected_err = pcall(select_entries, { "invalid" })
        vim.cmd.buffer = buffer_command
        assert(not selected_ok and tostring(selected_err):find("Vim:E37:", 1, true))
        assert(state.closed == 1 and state.cleared == 1)
    end)

    check("multi-selection delegates after closing the picker", function()
        setup_picker()
        local selected = { "one", "two" }
        select_entries(selected)
        assert(state.fallback.selected == selected)
        assert(state.fallback.opts == picker_opts)
    end)

    check("missing and invalid source windows use the fallback", function()
        for _, source in ipairs({ false, -1 }) do
            setup_picker()
            active_window.src_winid = source or nil
            select_entries({ "one" })
            assert(state.fallback)
        end
    end)

    check("unrelated errors still propagate after cleanup", function()
        setup_picker()
        state.fallback_error = "deliberate failure"
        local selected_ok, selected_err = pcall(select_entries, { "one", "two" })
        assert(not selected_ok and tostring(selected_err):find("deliberate failure", 1, true))
        assert(state.closed == 1 and state.cleared == 1)
    end)
end, debug.traceback)

for _, job in ipairs(jobs) do
    pcall(vim.fn.jobstop, job)
end
for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end
local resolved_root = vim.fs.normalize(assert(vim.uv.fs_realpath(test_root)))
local resolved_parent = vim.fs.normalize(assert(vim.uv.fs_realpath(test_parent)))
assert(vim.fs.dirname(resolved_root) == resolved_parent, "unsafe fixture cleanup path")
vim.fn.delete(test_root, "rf")
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd.cquit()
end
print(("%d dashboard picker checks passed"):format(passed))
vim.cmd.qa({ bang = true })
