local M = {}

-- Chỉ cần đổi dòng này để chọn theme.
M.name = "catppuccin-macchiato"

M.nord = {
    contrast = false,
    borders = false,
    disable_background = true,
    italic = true,
    uniform_diff_background = true,
    bold = true,
}

M.kanagawa = {
    overrides = function(colors)
        local theme = colors.theme
        return {
            NoiceCmdlinePopup = { fg = theme.ui.fg, bg = theme.ui.bg_p1 },
            NoiceCmdlinePopupBorder = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p1 },
            NoiceCmdlinePopupTitle = { fg = theme.ui.special, bg = theme.ui.bg_p1 },
            NoiceCmdlinePrompt = { fg = theme.ui.special },
            NoiceCmdlineIcon = { fg = theme.ui.special },
        }
    end,
}

local function get_hl(name)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    return ok and hl or {}
end

function M.apply_ui_highlights()
    local links = {
        NoiceCmdlinePopup = "NormalFloat",
        NoiceCmdlinePopupBorder = "FloatBorder",
        NoiceCmdlinePopupTitle = "FloatTitle",
        NoiceCmdlinePrompt = "Title",
        NoiceCmdlineIcon = "Special",
        NeoTreeNormal = "Normal",
        NeoTreeNormalNC = "NormalNC",
        NeoTreeDirectoryName = "Directory",
        NeoTreeDirectoryIcon = "Directory",
        NeoTreeFloatBorder = "FloatBorder",
        NeoTreeFloatTitle = "FloatTitle",
        AvanteConflictCurrent = "DiffText",
        AvanteConflictCurrentLabel = "DiffText",
        AvanteConflictIncoming = "DiffAdd",
        AvanteConflictIncomingLabel = "DiffAdd",
        NotifyBackground = "NormalFloat",
    }

    for group, link in pairs(links) do
        vim.api.nvim_set_hl(0, group, { link = link })
    end

    local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "EndOfBuffer",
        "MsgArea",
    }

    for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
    end

    local normal = get_hl("Normal")
    local pmenu = get_hl("Pmenu")
    local selection = get_hl("CursorLine")

    if not selection.bg then
        selection = get_hl("Visual")
    end

    local menu_fg = pmenu.fg or normal.fg
    local menu_sel_bg = selection.bg or 2387238

    vim.api.nvim_set_hl(0, "Pmenu", { fg = menu_fg, bg = "none", blend = 12 })
    vim.api.nvim_set_hl(0, "PmenuSel", { fg = menu_fg, bg = menu_sel_bg, bold = true, blend = 0 })
    vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { link = "PmenuSel" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("SungpThemeUI", { clear = true }),
    callback = function()
        vim.schedule(M.apply_ui_highlights)
    end,
})

function M.load()
    vim.cmd.colorscheme(M.name)
    M.apply_ui_highlights()
end

return M
