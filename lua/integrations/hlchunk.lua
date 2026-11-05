local M = require("helper.utils")
local hlchunk = M.safe_require("hlchunk")

if hlchunk then
    local function get_hl(name, fallback)
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        if next(hl) ~= nil then
            return hl
        end
        return vim.api.nvim_get_hl(0, { name = fallback, link = false })
    end

    local exclude_ft = {
        bigfile = true,
        snacks_dashboard = true,
        snacks_picker_input = true,
        snacks_picker_list = true,
        codecompanion = true,
        terminal = true,
        toggleterm = true,
        fzf = true,
        ["neo-tree"] = true,
    }

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("SungpHlchunkCleanup", { clear = true }),
        callback = function(args)
            if exclude_ft[vim.bo[args.buf].filetype] then
                local namespaces = vim.api.nvim_get_namespaces()
                for _, name in ipairs({ "chunk", "indent", "blank", "line_num" }) do
                    if namespaces[name] then
                        vim.api.nvim_buf_clear_namespace(args.buf, namespaces[name], 0, -1)
                    end
                end
            end
        end,
    })

    hlchunk.setup({
        chunk = {
            enable = true,
            use_treesitter = true,
            textobject = "iH",
            style = function()
                return {
                    get_hl("Special", "Directory"),
                    get_hl("DiagnosticError", "ErrorMsg"),
                }
            end,
            chars = {
                left_arrow = "─",
                horizontal_line = "─",
                vertical_line = "│",
                left_top = "╭",
                left_bottom = "╰",
                right_arrow = ">",
            },
            exclude_filetypes = exclude_ft,
            -- Avoid the plugin's async animation path, which can produce
            -- mismatched render state and crash on cursor moves.
            delay = 0,
            max_file_size = 1024 * 1024,
            priority = 15,
        },
        indent = {
            enable = true,
            -- Treesitter main no longer exposes the get_indent API used by hlchunk.
            use_treesitter = false,
            style = function()
                return { get_hl("Whitespace", "NonText") }
            end,
            exclude_filetypes = exclude_ft,
            chars = { "│" },
            priority = 10,
            ahead_lines = 5,
            delay = 100,
        },
    })

    -- shortcut: upstream shares indent caches across modules; reload for isolation until fixed.
    local indent_source = vim.api.nvim_get_runtime_file("lua/hlchunk/mods/indent/init.lua", false)[1]
    assert(indent_source, "hlchunk indent module missing")
    local Blank = assert(loadstring(table.concat(vim.fn.readfile(indent_source), "\n"), "@" .. indent_source))()
    local blank = Blank({
        enable = true,
        use_treesitter = false,
        style = function()
            return { get_hl("Whitespace", "NonText") }
        end,
        exclude_filetypes = exclude_ft,
        chars = { "·" },
        filter_list = {
            function(info)
                return vim.fn.getline(info.lnum + 1):match("^%s*$") ~= nil
            end,
        },
    }, {
        name = "blank",
        augroup_name = "hlchunk_blank",
        hl_base_name = "HLBlank",
        ns_id = vim.api.nvim_create_namespace("blank"),
    })
    blank:enable()

    local line_num = require("hlchunk.mods.line_num")({
        enable = true,
        use_treesitter = true,
        style = function()
            return { get_hl("Special", "Directory") }
        end,
        exclude_filetypes = exclude_ft,
        priority = 10,
    })
    -- shortcut: uses hlchunk's module lifecycle API, recheck this adapter on plugin upgrades.
    line_num.createAutocmd = function(self)
        require("hlchunk.mods.base_mod").createAutocmd(self)
        local previous
        vim.api.nvim_create_autocmd(
            { "CursorMoved", "CursorMovedI", "BufWinEnter", "TextChanged", "TextChangedI", "FileType" },
            {
                group = self.meta.augroup_name,
                callback = function(args)
                    local buf = args.buf
                    if buf ~= vim.api.nvim_get_current_buf() then
                        return
                    end
                    local scope = { bufnr = buf, start = 0, finish = vim.api.nvim_buf_line_count(buf) - 1 }
                    if not self:shouldRender(buf) then
                        self:clear(scope)
                        previous = nil
                        return
                    end
                    local pos = vim.api.nvim_win_get_cursor(0)
                    local helper = require("hlchunk.utils.chunkHelper")
                    local code, range = helper.get_chunk_range({
                        pos = { bufnr = buf, row = pos[1] - 1, col = pos[2] },
                        use_treesitter = true,
                    })
                    local key = table.concat(
                        { buf, vim.api.nvim_buf_get_changedtick(buf), code, range.start, range.finish },
                        ":"
                    )
                    if previous == key then
                        return
                    end
                    previous = key
                    self:clear(scope)
                    if code == helper.CHUNK_RANGE_RET.OK then
                        self:render(range)
                    end
                end,
            }
        )
    end
    line_num:enable()
end
