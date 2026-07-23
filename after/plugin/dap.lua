local M = require("helper.utils")

local dap_state
local dap_plugins = {
    "nvim-dap",
    "nvim-nio",
    "nvim-dap-ui",
    "nvim-dap-virtual-text",
}

local function ensure_dap()
    if dap_state then
        return dap_state
    end

    if not M.load_plugins(dap_plugins) then
        return nil
    end

    local dap = M.safe_require("dap")
    if not dap then
        return nil
    end

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

    dap_state = { dap = dap, dapui = dapui }
    return dap_state
end

local function with_dap(action)
    return function()
        local state = ensure_dap()
        if state then
            action(state.dap, state.dapui)
        end
    end
end

vim.keymap.set("n", "<F5>", with_dap(function(dap)
    dap.continue()
end), { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", with_dap(function(dap)
    dap.step_over()
end), { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", with_dap(function(dap)
    dap.step_into()
end), { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", with_dap(function(dap)
    dap.step_out()
end), { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", with_dap(function(dap)
    dap.toggle_breakpoint()
end), { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", with_dap(function(dap)
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end), { desc = "Debug: Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", with_dap(function(dap)
    dap.repl.open()
end), { desc = "Debug: Open REPL" })
vim.keymap.set("n", "<leader>dl", with_dap(function(dap)
    dap.run_last()
end), { desc = "Debug: Run Last" })
vim.keymap.set("n", "<leader>du", with_dap(function(_, dapui)
    if dapui then
        dapui.toggle()
    end
end), { desc = "Debug: Toggle UI" })
