-- Full plugin configuration smoke test with isolated
-- writable data. Uses installed plugins/parsers; never updates or installs them.
-- nvim --headless -u NONE -i NONE -l tests/startup.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local data = vim.fn.stdpath("data")
local plugins = vim.env.SUNGP_TEST_PLUGIN_ROOT or (data .. "/lazy")
local fixture = vim.fn.tempname() .. "-nvim-startup"
assert(not vim.uv.fs_stat(fixture))
vim.fn.mkdir(fixture, "p")
local real = assert(vim.uv.fs_realpath(fixture))
local project_dir = fixture .. "/project with spaces"
vim.fn.mkdir(project_dir, "p")
vim.fn.writefile({ "first line", "second line" }, project_dir .. "/sample.txt")
local init = string.format(
    [[
local function trace(message) vim.fn.writefile({message}, vim.env.NVIM_LOG_FILE .. ".trace", "a") end
trace("init begin")
vim.opt.runtimepath:prepend(%q)
vim.opt.runtimepath:prepend(%q)
vim.opt.runtimepath:append(%q)
vim.g.sungp_animations = false
_G.smoke_errors = {}
local notify = vim.notify
vim.notify = function(message, level, opts)
  if level == vim.log.levels.ERROR then table.insert(_G.smoke_errors, tostring(message)) end
  return notify(message, level, opts)
end
package.preload["config.lazy"] = function()
  trace("lazy begin")
  require("lazy").setup({
    root = %q,
    lockfile = %q,
    spec = {
      { import = "plugins" },
      { "nvim-treesitter/nvim-treesitter", build = false, config = function()
        local ts = require("nvim-treesitter")
        ts.setup({ install_dir = %q })
        ts.install = function() return { await = function(_, callback) callback(nil) end } end
        require("integrations.treesitter")
      end },
      { "WhoIsSethDaniel/mason-tool-installer.nvim", enabled = false },
    },
    defaults = { lazy = true, version = false },
    install = { missing = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
    rocks = { enabled = false },
    performance = { rtp = { reset = false } },
  })
  trace("lazy ready")
  require("config.theme").load()
  trace("theme ready")
end
require("config")
trace("config ready")
vim.api.nvim_create_autocmd("VimEnter", { callback = function()
  trace("VimEnter " .. vim.inspect(_G.smoke_errors))
  vim.defer_fn(function() trace("after enter " .. vim.api.nvim_get_mode().mode .. " " .. vim.v.errmsg) end, 500)
end })
]],
    root,
    plugins .. "/lazy.nvim",
    data .. "/site",
    plugins,
    fixture .. "/lazy-lock.json",
    data .. "/site"
)
vim.fn.writefile(vim.split(init, "\n"), fixture .. "/init.lua")

local jobs = {}
local function request(job, method, ...)
    return vim.rpcnotify(job, method, ...)
end
local result_id = 0
local function lua(job, code)
    result_id = result_id + 1
    local result_file = fixture .. "/result-" .. result_id .. ".json"
    local wrapped = string.format(
        [[local ok, result = pcall(function() %s end)
      vim.fn.writefile({vim.json.encode({ok = ok, result = result})}, %q)]],
        code,
        result_file
    )
    request(job, "nvim_exec_lua", wrapped, {})
    assert(
        vim.wait(5000, function()
            return vim.fn.filereadable(result_file) == 1
        end),
        "RPC test timed out: " .. code
    )
    local result = vim.json.decode(table.concat(vim.fn.readfile(result_file), "\n"))
    assert(result.ok, result.result)
    return result.result
end
local function launch(file)
    local args = { vim.v.progpath, "--embed", "--headless", "-i", "NONE", "-n", "-u", fixture .. "/init.lua" }
    if file then
        table.insert(args, file)
    end
    local job = vim.fn.jobstart(args, {
        rpc = true,
        cwd = project_dir,
        on_stderr = function(_, lines)
            for _, line in ipairs(lines) do
                if line ~= "" then
                    print("CHILD: " .. line)
                end
            end
        end,
        env = {
            XDG_CONFIG_HOME = fixture .. "/config",
            XDG_DATA_HOME = fixture .. "/data",
            XDG_STATE_HOME = fixture .. "/state",
            XDG_CACHE_HOME = fixture .. "/cache",
            NVIM_APPNAME = "nvim",
            NVIM_LOG_FILE = fixture .. "/nvim.log",
        },
    })
    assert(job > 0)
    jobs[#jobs + 1] = job
    vim.defer_fn(function()
        if vim.fn.jobwait({ job }, 0)[1] == -1 then
            vim.fn.jobstop(job)
        end
    end, 45000)
    return job
end

local ok, err = xpcall(function()
    local job = launch(project_dir .. "/sample.txt")
    request(job, "nvim_input", "ihello")
    vim.wait(1500)
    assert(lua(job, "return vim.api.nvim_get_mode().mode") == "i", "first insert did not enter Insert mode")
    assert(
        lua(job, "return vim.fn.maparg('<Tab>', 'i', false, true).buffer") == 1,
        "Blink first-insert mapping missing"
    )
    assert(lua(job, "return vim.api.nvim_get_current_line():sub(1, 5)") == "hello", "first typed characters lost")
    request(job, "nvim_input", "<Esc>")
    vim.wait(100)
    lua(
        job,
        [[
      for _, key in ipairs({ 'ff', 'fg', 'fF', 'fG', 'fE', 'fN', 'fR', 'fw', 'fl', 'fO', 'fk',
          'uz', 'uZ', 'u.', 'uS', 'uw', 'ud', 'uf', 'uF', 'up', 'uP', 'ua', 'ui', 'uc', 'ub' }) do
        local mapping = vim.fn.maparg(' ' .. key, 'n', false, true)
        assert(mapping.desc, 'missing key: ' .. key)
      end
      assert(vim.fn.maparg(' fw', 'x', false, true).desc, 'visual grep mapping missing')
      assert(require('lazy.core.config').plugins['snacks.nvim']._.loaded)
      assert(#_G.smoke_errors == 0, table.concat(_G.smoke_errors, '\n'))
    ]]
    )
    print("PASS full plugin startup, first Insert/Blink, and new keymap registration")

    -- Both pickers execute the installed fzf/rg binaries with a real terminal
    -- buffer, while all test files and histories stay under the fixture.
    for _, provider in ipairs({ "files", "live_grep", "live_grep_native" }) do
        print("Checking " .. provider)
        local options = provider == "files" and "{}" or "{ search = 'line' }"
        lua(job, "require('fzf-lua')." .. provider .. "(" .. options .. ")")
        vim.wait(500)
        assert(lua(job, "return require('fzf-lua.utils').fzf_winobj() ~= nil"), provider .. " did not open")
        lua(
            job,
            [[
          local rendered = ''
          assert(vim.wait(3000, function()
            local win = require('fzf-lua.utils').fzf_winobj()
            local lines = vim.api.nvim_buf_get_lines(win.fzf_bufnr, 0, -1, false)
            rendered = table.concat(lines, '\n')
            return rendered:find('sample.txt', 1, true) ~= nil
          end), 'picker did not return sample.txt: ' .. rendered)
        ]]
        )
        lua(job, "require('fzf-lua.utils').fzf_winobj():close()")
        vim.wait(100)
    end
    lua(job, "assert(#_G.smoke_errors == 0, table.concat(_G.smoke_errors, '\\n'))")
    print("PASS installed file and native grep picker smoke checks")
end, debug.traceback)

for _, job in ipairs(jobs) do
    vim.fn.jobstop(job)
    vim.fn.jobwait({ job }, 2000)
end
assert(vim.uv.fs_realpath(fixture) == real, "fixture path changed")
assert(fixture:match("%-nvim%-startup$"), "unsafe cleanup path")
if not ok and vim.fn.filereadable(fixture .. "/nvim.log.trace") == 1 then
    print(table.concat(vim.fn.readfile(fixture .. "/nvim.log.trace"), "\n"))
end
vim.fn.delete(fixture, "rf")
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd.cquit()
end
print("Full startup checks passed")
vim.cmd.qa({ bang = true })
