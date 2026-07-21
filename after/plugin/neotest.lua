local M = require("helper.utils")
local neotest = M.safe_require("neotest")

if neotest then
    local adapters = {}
    local python = M.safe_require("neotest-python")
    local jest = M.safe_require("neotest-jest")
    local golang = M.safe_require("neotest-golang")

    if python then
        table.insert(adapters, python({}))
    end

    if jest then
        table.insert(adapters, jest({}))
    end

    if golang then
        table.insert(adapters, golang({}))
    end

    neotest.setup({
        adapters = adapters,
    })

    vim.keymap.set("n", "<leader>nt", function() neotest.run.run() end, { desc = "Test: Nearest" })
    vim.keymap.set("n", "<leader>nf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test: File" })
    vim.keymap.set("n", "<leader>nT", function() neotest.run.run(vim.loop.cwd()) end, { desc = "Test: Project" })
    vim.keymap.set("n", "<leader>ns", neotest.summary.toggle, { desc = "Test: Summary" })
    vim.keymap.set("n", "<leader>no", neotest.output.open, { desc = "Test: Output" })
    vim.keymap.set("n", "<leader>nO", function() neotest.output_panel.toggle() end, { desc = "Test: Output Panel" })
    vim.keymap.set("n", "<leader>nw", neotest.watch.toggle, { desc = "Test: Watch" })
end
