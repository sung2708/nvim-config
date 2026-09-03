local excluded_filetypes = {
    "DressingInput",
    "NvimTree",
    "TelescopePrompt",
    "alpha",
    "dashboard",
    "fzf",
    "lazy",
    "mason",
    "neo-tree",
    "noice",
    "oil",
    "qf",
    "snacks_dashboard",
    "snacks_picker_input",
    "trouble",
}

local function is_enabled(bufnr, winid)
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(winid) then
        return false
    end
    if vim.g.sungp_breadcrumbs == false or vim.b[bufnr].bigfile then
        return false
    end

    -- Leave plugin-owned windows alone. This keeps the dashboard, explorers,
    -- pickers, terminals, help and quickfix windows visually focused.
    if vim.fn.win_gettype(winid) ~= "" or vim.wo[winid].winbar ~= "" or vim.bo[bufnr].buftype ~= "" then
        return false
    end

    if vim.tbl_contains(excluded_filetypes, vim.bo[bufnr].filetype) then
        return false
    end

    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return false
    end

    local stat = vim.uv.fs_stat(filename)
    return not stat or stat.size <= 1024 * 1024
end

local dropbar = require("dropbar")
local dropbar_configs = require("dropbar.configs")
local treesitter_valid_types = vim.deepcopy(dropbar_configs.opts.sources.treesitter.valid_types)
local treesitter_node_kinds = {
    { "for_range_loop", "ForStatement" },
    { "enhanced_for_statement", "ForStatement" },
    { "for_in_statement", "ForStatement" },
    { "for_of_statement", "ForStatement" },
    { "for_each_statement", "ForStatement" },
    { "foreach_statement", "ForStatement" },
    { "c_style_for_statement", "ForStatement" },
    { "for_expression", "ForStatement" },
    { "loop_expression", "Repeat" },
    { "while_expression", "WhileStatement" },
    { "do_while_statement", "DoStatement" },
    { "do_while_expression", "DoStatement" },
    { "if_expression", "IfStatement" },
    { "if_clause", "IfStatement" },
    { "unless_statement", "IfStatement" },
    { "elif_clause", "IfStatement" },
    { "else_clause", "IfStatement" },
    { "match_expression", "SwitchStatement" },
    { "switch_expression", "SwitchStatement" },
    { "switch_case", "CaseStatement" },
    { "case_clause", "CaseStatement" },
    { "case_block", "CaseStatement" },
    { "until_statement", "WhileStatement" },
    { "try_statement", "Scope" },
    { "catch_clause", "Scope" },
    { "except_clause", "Scope" },
    { "finally_clause", "Scope" },
}

local treesitter_icons = {}
for _, node_kind in ipairs(treesitter_node_kinds) do
    local node_type, icon_kind = node_kind[1], node_kind[2]
    table.insert(treesitter_valid_types, node_type)

    local icon_name = node_type:gsub("^%l", string.upper):gsub("_%l", string.upper):gsub("_", "")
    treesitter_icons[icon_name] = dropbar_configs.opts.icons.kinds.symbols[icon_kind]
end

dropbar.setup({
    icons = {
        kinds = {
            symbols = treesitter_icons,
        },
    },
    sources = {
        treesitter = {
            valid_types = treesitter_valid_types,
        },
    },
    bar = {
        enable = is_enabled,
        -- Prefer Treesitter so language-specific control-flow nodes are
        -- included. The default fallback prefers LSP, whose document symbols
        -- usually contain functions/classes but not those nodes.
        sources = function(_, _)
            local sources = require("dropbar.sources")
            local utils = require("dropbar.utils")

            return {
                sources.path,
                utils.source.fallback({
                    sources.treesitter,
                    sources.lsp,
                }),
            }
        end,
        padding = {
            left = 1,
            right = 1,
        },
        -- Avoid redrawing repeatedly while moving quickly through large files.
        update_debounce = 80,
    },
    menu = {
        win_configs = {
            border = "rounded",
        },
    },
})

local M = {}
function M.toggle()
    vim.g.sungp_breadcrumbs = vim.g.sungp_breadcrumbs == false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.g.sungp_breadcrumbs then
            require("dropbar.utils").bar.attach(buf, win)
        elseif vim.wo[win].winbar:find("v:lua.dropbar", 1, true) then
            vim.wo[win].winbar = ""
            local bar = require("dropbar.api").get_dropbar(buf, win)
            if bar then
                bar:del()
            end
        end
    end
end
return M
