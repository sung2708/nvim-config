local M = require("helper.utils")
local dap = M.safe_require("dap")

if dap then
    local dapui = M.safe_require("dapui")
    local virtual_text = M.safe_require("nvim-dap-virtual-text")

    if virtual_text then
        virtual_text.setup({})
    end

    if dapui then
        dapui.setup({})
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end
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
    vim.keymap.set("n", "<leader>du", function()
        if dapui then
            dapui.toggle()
        end
    end, { desc = "Debug: Toggle UI" })
end
