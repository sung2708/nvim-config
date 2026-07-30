local M = {}

-- Chỉ cần đổi dòng này để chọn theme.
M.name = "catppuccin-macchiato"

M.nord = {
    contrast = false,
    borders = false,
    disable_background = false,
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
    }

    for group, link in pairs(links) do
        vim.api.nvim_set_hl(0, group, { link = link })
    end
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
