local neotest = require("neotest")
local adapters = {}

local function add_adapter(module_name)
    local ok, adapter = pcall(require, module_name)
    if not ok then
        return
    end

    local configured_ok, configured = pcall(adapter, {})
    if configured_ok then
        table.insert(adapters, configured)
    else
        vim.notify(module_name .. " is incompatible with the installed neotest version", vim.log.levels.WARN)
    end
end

add_adapter("neotest-python")
add_adapter("neotest-jest")
add_adapter("neotest-golang")
add_adapter("neotest-java")

neotest.setup({
    adapters = adapters,
    quickfix = {
        open = false,
    },
    output = {
        open_on_run = false,
    },
})

vim.api.nvim_create_user_command("NeotestSummary", function()
    neotest.summary.toggle()
end, {})

vim.keymap.set("n", "<leader>nt", function()
    neotest.run.run()
end, { desc = "Test: Nearest" })
vim.keymap.set("n", "<leader>nf", function()
    neotest.run.run(vim.fn.expand("%"))
end, { desc = "Test: File" })
vim.keymap.set("n", "<leader>nT", function()
    neotest.run.run(vim.uv.cwd())
end, { desc = "Test: Project" })
vim.keymap.set("n", "<leader>ns", neotest.summary.toggle, { desc = "Test: Summary" })
vim.keymap.set("n", "<leader>no", neotest.output.open, { desc = "Test: Output" })
vim.keymap.set("n", "<leader>nO", neotest.output_panel.toggle, { desc = "Test: Output Panel" })
vim.keymap.set("n", "<leader>nw", neotest.watch.toggle, { desc = "Test: Watch" })
