local utils = require("helper.utils")
local opencode = utils.safe_require("opencode")

if not opencode then
    return
end

---------------------------------------------------------------------------
-- OPTIONAL SETUP (chỉ chạy nếu plugin có setup)
---------------------------------------------------------------------------
if type(opencode.setup) == "function" then
    opencode.setup({
        input = {},
        picker = {
            actions = {
                opencode_send = function(...)
                    local ok, mod = pcall(require, "opencode")
                    if ok and mod.snacks_picker_send then
                        return mod.snacks_picker_send(...)
                    end
                end,
            },
            win = {
                input = {
                    keys = {
                        ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                    },
                },
            },
        },
    })
end

---------------------------------------------------------------------------
-- SYSTEM
---------------------------------------------------------------------------
vim.o.autoread = true

---------------------------------------------------------------------------
-- SAFE WRAPPER
---------------------------------------------------------------------------
local function oc()
    local ok, mod = pcall(require, "opencode")
    if ok then
        return mod
    end
end

---------------------------------------------------------------------------
-- KEYMAPS
---------------------------------------------------------------------------

-- Ask AI
vim.keymap.set({ "n", "x" }, "<leader>oa", function()
    local m = oc()
    if m and m.ask then
        m.ask("@this: ", { submit = true })
    end
end, { desc = "Opencode: Ask AI" })

-- Actions picker
vim.keymap.set({ "n", "x" }, "<leader>ox", function()
    local m = oc()
    if m and m.select then
        m.select()
    end
end, { desc = "Opencode: Actions" })

-- Toggle window
local function toggle_fn()
    local m = oc()
    if m and m.toggle then
        m.toggle()
    end
end

vim.keymap.set({ "n", "t" }, "<leader>oo", toggle_fn, { desc = "Opencode: Toggle" })
vim.keymap.set({ "n", "t" }, "<leader>.", toggle_fn, { desc = "Opencode: Toggle" })

-- Operator (add range)
vim.keymap.set({ "n", "x" }, "go", function()
    local m = oc()
    if m and m.operator then
        return m.operator("@this ")
    end
    return ""
end, { expr = true, desc = "Opencode: Add range" })

-- Add current line
vim.keymap.set("n", "goo", function()
    local m = oc()
    if m and m.operator then
        return m.operator("@this ") .. "_"
    end
    return ""
end, { expr = true, desc = "Opencode: Add line" })

-- Scroll up
vim.keymap.set("n", "<S-C-u>", function()
    local m = oc()
    if m and m.command then
        m.command("session.half.page.up")
    end
end, { desc = "Opencode: Scroll Up" })

-- Scroll down
vim.keymap.set("n", "<S-C-d>", function()
    local m = oc()
    if m and m.command then
        m.command("session.half.page.down")
    end
end, { desc = "Opencode: Scroll Down" })
