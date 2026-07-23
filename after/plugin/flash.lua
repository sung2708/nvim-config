local M = require("helper.utils")

local flash_instance

local function ensure_flash()
    if flash_instance then
        return flash_instance
    end

    if not M.load_plugins({ "flash.nvim" }) then
        return nil
    end

    flash_instance = M.safe_require("flash")
    if flash_instance then
        flash_instance.setup({
            highlight = { groups = { flash = "Flash" } },
        })
    end
    return flash_instance
end

vim.keymap.set({ "n", "x", "o" }, "s", function()
    local flash = ensure_flash()
    if flash then
        flash.jump()
    end
end, { desc = "Flash: Jump" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
    local flash = ensure_flash()
    if flash then
        flash.treesitter()
    end
end, { desc = "Flash: Treesitter" })
