local M = require("helper.utils")
local snacks = M.safe_require("snacks")

if snacks then
    local function dashboard_header()
        local lines = {
            "███████╗██╗   ██╗███╗   ██╗ ██████╗ ██████╗",
            "██╔════╝██║   ██║████╗  ██║██╔════╝ ██╔══██╗",
            "███████╗██║   ██║██╔██╗ ██║██║  ███╗██████╔╝",
            "╚════██║██║   ██║██║╚██╗██║██║   ██║██╔═══╝",
            "███████║╚██████╔╝██║ ╚████║╚██████╔╝██║",
            "╚══════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝",
        }
        local width = 0

        for _, line in ipairs(lines) do
            width = math.max(width, vim.fn.strdisplaywidth(line))
        end
        for index, line in ipairs(lines) do
            lines[index] = line .. string.rep(" ", width - vim.fn.strdisplaywidth(line))
        end

        return table.concat(lines, "\n")
    end

    local dashboard_chrome

    local function hide_dashboard_chrome()
        dashboard_chrome = dashboard_chrome or {
            laststatus = vim.o.laststatus,
            showtabline = vim.o.showtabline,
        }
        vim.o.laststatus = 0
        vim.o.showtabline = 0
    end

    local function restore_dashboard_chrome()
        if not dashboard_chrome then
            return
        end
        vim.o.laststatus = dashboard_chrome.laststatus
        vim.o.showtabline = dashboard_chrome.showtabline
        dashboard_chrome = nil
    end

    local function setup_bigfile(ctx)
        vim.b[ctx.buf].bigfile = true
        vim.b[ctx.buf].completion = false
        vim.b[ctx.buf].minianimate_disable = true
        vim.b[ctx.buf].minihipatterns_disable = true

        if vim.fn.exists(":NoMatchParen") ~= 0 then
            vim.cmd("NoMatchParen")
        end

        snacks.util.wo(0, {
            conceallevel = 0,
            cursorcolumn = false,
            cursorline = false,
            foldmethod = "manual",
            relativenumber = false,
            statuscolumn = "",
        })

        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ctx.buf) then
                vim.bo[ctx.buf].syntax = ctx.ft
            end
        end)
    end

    snacks.setup({
        bigfile = {
            enabled = true,
            line_length = 500,
            setup = setup_bigfile,
            size = 1024 * 1024,
        },
        quickfile = { enabled = true },
        dashboard = {
            enabled = true,
            width = 58,
            row = nil,
            col = nil,
            pane_gap = 2,
            preset = {
                header = dashboard_header(),
                keys = {
                    {
                        icon = " ",
                        key = "f",
                        desc = "Find File",
                        action = function()
                            Snacks.dashboard.pick("files")
                        end,
                    },
                    {
                        icon = "󰱼 ",
                        key = "g",
                        desc = "Live Grep",
                        action = function()
                            Snacks.dashboard.pick("live_grep")
                        end,
                    },
                    {
                        icon = "󰈚 ",
                        key = "b",
                        desc = "Buffers",
                        action = function()
                            Snacks.dashboard.pick("buffers")
                        end,
                    },
                    { icon = "󰉋 ", key = "e", desc = "File Explorer", action = ":Neotree filesystem reveal left" },
                    { icon = "󰊢 ", key = "s", desc = "Git Status", action = ":Git" },
                    { icon = "󰦓 ", key = "d", desc = "Diff View", action = ":DiffviewOpen" },
                    { icon = "󰒡 ", key = "x", desc = "Diagnostics", action = ":Trouble diagnostics toggle" },
                    { icon = "󰙨 ", key = "t", desc = "Test Summary", action = ":NeotestSummary" },
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = function()
                            Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })
                        end,
                    },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { section = "header", padding = { 1, 2 } },
                { section = "keys", gap = 0, padding = { 0, 1 } },
                {
                    icon = " ",
                    title = "Recent Files",
                    section = "recent_files",
                    limit = 4,
                    indent = 1,
                    padding = { 1, 1 },
                },
                {
                    icon = " ",
                    title = "Git Status",
                    section = "terminal",
                    enabled = function()
                        return snacks.git.get_root() ~= nil
                    end,
                    cmd = "git status --short --branch --renames",
                    height = 5,
                    padding = { 1, 0 },
                    ttl = 60,
                    indent = 1,
                },
            },
        },
        picker = {
            sources = {
                files = {
                    cmd = "fd",
                    hidden = false,
                    ignored = false,
                    exclude = { "node_modules", "dist", "build", "target", ".next", "coverage" },
                },
            },
        },
    })

    local dashboard_group = vim.api.nvim_create_augroup("SungpDashboardChrome", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        group = dashboard_group,
        pattern = "SnacksDashboardOpened",
        callback = hide_dashboard_chrome,
    })
    vim.api.nvim_create_autocmd("User", {
        group = dashboard_group,
        pattern = "SnacksDashboardClosed",
        callback = restore_dashboard_chrome,
    })
    vim.api.nvim_create_autocmd("User", {
        group = dashboard_group,
        pattern = "VeryLazy",
        callback = function()
            vim.schedule(function()
                if vim.bo.filetype == "snacks_dashboard" then
                    hide_dashboard_chrome()
                end
            end)
        end,
    })

    vim.keymap.set("n", "<leader>sd", function()
        snacks.dashboard()
    end, { desc = "Dashboard: Open" })
end
