local M = require("helper.utils")

local trouble_instance
local wrapper_active = true

local function ensure_trouble()
    if trouble_instance then
        return trouble_instance
    end

    if not M.load_plugins({ "trouble.nvim" }) then
        return nil
    end

    trouble_instance = M.safe_require("trouble")
    if not trouble_instance then
        return nil
    end

    if wrapper_active and vim.fn.exists(":Trouble") == 2 then
        vim.api.nvim_del_user_command("Trouble")
    end
    trouble_instance.setup({})
    wrapper_active = false
    return trouble_instance
end

vim.api.nvim_create_user_command("Trouble", function(opts)
    if ensure_trouble() then
        local command = "Trouble"
        if opts.args ~= "" then
            command = command .. " " .. opts.args
        end
        vim.cmd(command)
    end
end, {
    nargs = "*",
    desc = "Open Trouble",
})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: Workspace Diagnostics" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Trouble: Buffer Diagnostics" })
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Trouble: Symbols" })
vim.keymap.set("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "Trouble: LSP" })
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble: Location List" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble: Quickfix List" })
