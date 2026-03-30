local utils = require("helper.utils")

---------------------------------------------------------------------------
-- GLOBAL CONFIG
---------------------------------------------------------------------------
vim.g.opencode_opts = {
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
                    ["<A-a>"] = {
                        action = "opencode_send",
                        mode = { "n", "i" },
                    },
                },
            },
        },
    },
}

---------------------------------------------------------------------------
-- SAFE REQUIRE
---------------------------------------------------------------------------
local function oc()
    local ok, mod = pcall(require, "opencode")
    if ok then
        return mod
    end
end

---------------------------------------------------------------------------
-- SYSTEM
---------------------------------------------------------------------------
vim.o.autoread = true

---------------------------------------------------------------------------
-- BLOCK AUTO EDIT FROM AI
---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("User", {
    pattern = "OpencodeEvent:*",
    callback = function(args)
        local event = args.data and args.data.event
        if not event then return end

        if event.type == "file.edited" then
            vim.schedule(function()
                vim.cmd("undo")
                vim.notify("Opencode attempted to edit file (blocked)", vim.log.levels.WARN)
            end)
        end
    end,
})

---------------------------------------------------------------------------
-- KEYMAPS
---------------------------------------------------------------------------

vim.keymap.set({ "n", "x" }, "<leader>oa", function()
    local m = oc()
    if m and m.ask then
        m.ask("@this: ", { submit = true })
    end
end, { desc = "AI Ask" })

vim.keymap.set({ "n", "x" }, "<leader>oe", function()
    local m = oc()
    if m and m.prompt then
        m.prompt("explain @this")
    end
end, { desc = "Explain code" })

vim.keymap.set("n", "<leader>of", function()
    local m = oc()
    if m and m.prompt then
        m.prompt("fix @diagnostics")
    end
end, { desc = "Fix diagnostics" })

vim.keymap.set("n", "<leader>or", function()
    local m = oc()
    if m and m.prompt then
        m.prompt("review @diff")
    end
end, { desc = "Review changes" })

vim.keymap.set({ "n", "x" }, "<leader>oo", function()
    local m = oc()
    if m and m.prompt then
        m.prompt("optimize @this")
    end
end, { desc = "Optimize code" })

vim.keymap.set("n", "<leader>ot", function()
    local m = oc()
    if m and m.prompt then
        m.prompt("test @this")
    end
end, { desc = "Generate tests" })

vim.keymap.set({ "n", "x" }, "<leader>ox", function()
    local m = oc()
    if m and m.select then
        m.select()
    end
end, { desc = "AI Actions" })

vim.keymap.set({ "n", "t" }, "<leader>op", function()
    local m = oc()
    if m and m.toggle then
        m.toggle()
    end
end, { desc = "Toggle AI" })

vim.keymap.set({ "n", "x" }, "go", function()
    local m = oc()
    if m and m.operator then
        return m.operator("@this ")
    end
    return ""
end, { expr = true, desc = "Add to context" })

vim.keymap.set("n", "goo", function()
    local m = oc()
    if m and m.operator then
        return m.operator("@this ") .. "_"
    end
    return ""
end, { expr = true, desc = "Add line to context" })

vim.keymap.set("n", "<leader>ou", function()
    local m = oc()
    if m and m.command then
        m.command("session.undo")
    end
end, { desc = "Undo AI action" })

vim.keymap.set("n", "<leader>oU", function()
    local m = oc()
    if m and m.command then
        m.command("session.redo")
    end
end, { desc = "Redo AI action" })

vim.keymap.set("n", "<S-C-u>", function()
    local m = oc()
    if m and m.command then
        m.command("session.half.page.up")
    end
end)

vim.keymap.set("n", "<S-C-d>", function()
    local m = oc()
    if m and m.command then
        m.command("session.half.page.down")
    end
end)
