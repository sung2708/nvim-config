local M = require("helper.utils")
local snacks = M.safe_require("snacks")

if snacks then
    snacks.setup({
        bigfile = { enabled = true },
        quickfile = { enabled = true },
        dashboard = {
            enabled = true,
            width = 64,
            row = nil,
            col = nil,
            pane_gap = 4,
            preset = {
                header = 
                [[

███████╗██╗   ██╗███╗   ██╗ ██████╗ ██████╗⠀
██╔════╝██║   ██║████╗  ██║██╔════╝ ██╔══██╗
███████╗██║   ██║██╔██╗ ██║██║  ███╗██████╔╝
╚════██║██║   ██║██║╚██╗██║██║   ██║██╔═══╝⠀
███████║╚██████╔╝██║ ╚████║╚██████╔╝██║⠀⠀⠀⠀⠀
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝⠀⠀⠀⠀⠀

]],
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
                    { icon = "󰱼 ", key = "g", desc = "Live Grep", action = ":Telescope live_grep" },
                    { icon = "󰈚 ", key = "b", desc = "Buffers", action = ":Telescope buffers" },
                    { icon = "󰉋 ", key = "e", desc = "File Explorer", action = ":Neotree filesystem reveal left" },
                    { icon = "󰊢 ", key = "s", desc = "Git Status", action = ":Git" },
                    { icon = "󰦓 ", key = "d", desc = "Diff View", action = ":DiffviewOpen" },
                    { icon = "󰒡 ", key = "x", desc = "Diagnostics", action = ":Trouble diagnostics toggle" },
                    { icon = "󰙨 ", key = "t", desc = "Test Summary", action = function()
                        local ok, neotest = pcall(require, "neotest")
                        if ok then
                            neotest.summary.toggle()
                        else
                            vim.notify("neotest is not installed", vim.log.levels.WARN)
                        end
                    end },
                    { icon = " ", key = "c", desc = "Config", action = ":Telescope find_files cwd=" .. vim.fn.stdpath("config") },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { section = "header", padding = 1 },
                { section = "keys", gap = 1, padding = 1 },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 1, 1 } },
                {
                    icon = " ",
                    title = "Git Status",
                    section = "terminal",
                    enabled = function()
                        return snacks.git.get_root() ~= nil
                    end,
                    cmd = "git status --short --branch --renames",
                    height = 6,
                    padding = 1,
                    ttl = 60,
                    indent = 2,
                },
            },
        },
    })

    vim.keymap.set("n", "<leader>sd", function()
        snacks.dashboard()
    end, { desc = "Dashboard: Open" })
end
