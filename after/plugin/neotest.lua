local M = require("helper.utils")

local neotest_instance
local neotest_plugins = {
    "nvim-nio",
    "neotest",
    "neotest-python",
    "neotest-jest",
    "neotest-golang",
}

local function add_adapter(adapters, module_name)
    local adapter = M.safe_require(module_name)
    if not adapter then
        return
    end

    local ok, configured = pcall(adapter, {})
    if ok then
        table.insert(adapters, configured)
        return
    end

    vim.schedule(function()
        vim.notify(
            string.format("%s is incompatible with the installed neotest version", module_name),
            vim.log.levels.WARN
        )
    end)
end

local function ensure_neotest()
    if neotest_instance then
        return neotest_instance
    end

    if not M.load_plugins(neotest_plugins) then
        return nil
    end

    local neotest = M.safe_require("neotest")
    if not neotest then
        return nil
    end

    local adapters = {}
    add_adapter(adapters, "neotest-python")
    add_adapter(adapters, "neotest-jest")
    add_adapter(adapters, "neotest-golang")

    neotest.setup({
        adapters = adapters,
    })

    neotest_instance = neotest
    return neotest_instance
end

local function with_neotest(action)
    return function()
        local neotest = ensure_neotest()
        if neotest then
            action(neotest)
        end
    end
end

vim.api.nvim_create_user_command("NeotestSummary", with_neotest(function(neotest)
    neotest.summary.toggle()
end), {})

vim.keymap.set("n", "<leader>nt", with_neotest(function(neotest)
    neotest.run.run()
end), { desc = "Test: Nearest" })
vim.keymap.set("n", "<leader>nf", with_neotest(function(neotest)
    neotest.run.run(vim.fn.expand("%"))
end), { desc = "Test: File" })
vim.keymap.set("n", "<leader>nT", with_neotest(function(neotest)
    neotest.run.run(vim.uv.cwd())
end), { desc = "Test: Project" })
vim.keymap.set("n", "<leader>ns", with_neotest(function(neotest)
    neotest.summary.toggle()
end), { desc = "Test: Summary" })
vim.keymap.set("n", "<leader>no", with_neotest(function(neotest)
    neotest.output.open()
end), { desc = "Test: Output" })
vim.keymap.set("n", "<leader>nO", with_neotest(function(neotest)
    neotest.output_panel.toggle()
end), { desc = "Test: Output Panel" })
vim.keymap.set("n", "<leader>nw", with_neotest(function(neotest)
    neotest.watch.toggle()
end), { desc = "Test: Watch" })
