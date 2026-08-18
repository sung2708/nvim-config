local dap = require("dap")
local dapui = require("dapui")

require("nvim-dap-virtual-text").setup({})
dapui.setup({
    floating = {
        border = "rounded",
    },
})

require("mason-nvim-dap").setup({
    ensure_installed = { "python", "delve", "codelldb" },
    automatic_installation = true,
    handlers = {
        function(config)
            require("mason-nvim-dap").default_setup(config)
        end,
    },
})

require("dap-go").setup({})

local function setup_js_debug()
    local js_debug_server = vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

    if vim.fn.filereadable(js_debug_server) ~= 1 then
        return false
    end
    if vim.fn.executable("node") ~= 1 then
        vim.notify("Node.js is required for JavaScript debugging", vim.log.levels.WARN)
        return false
    end

    dap.adapters["pwa-node"] = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
            command = "node",
            args = { js_debug_server, "${port}" },
        },
    }

    local js_configurations = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch current file (Node)",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            console = "integratedTerminal",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
        },
    }

    for _, filetype in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
        dap.configurations[filetype] = js_configurations
    end
    return true
end

setup_js_debug()
vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsUpdateCompleted",
    callback = setup_js_debug,
})

if vim.fn.filereadable(
        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
    ) ~= 1 then
    vim.notify("JavaScript DAP adapter is not installed yet; run :MasonToolsInstall", vim.log.levels.WARN)
end

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
