local M = {}

-- Chỉ cần đổi dòng này để chọn theme.
M.name = "catppuccin-frappe"

M.nord = {
    contrast = false,
    borders = true,
    disable_background = false,
    italic = true,
    uniform_diff_background = true,
    bold = true,
}

M.kanagawa = {
    compile = true,
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
    local normal = get_hl("Normal")
    local normal_float = get_hl("NormalFloat")
    local float_border = get_hl("FloatBorder")
    local float_title = get_hl("FloatTitle")
    local non_text = get_hl("NonText")

    -- Keep every floating surface opaque while preserving all other
    -- colorscheme attributes. Border cells use the same surface background,
    -- so no foreign color can appear between the content and its outline.
    normal_float.fg = normal_float.fg or normal.fg
    normal_float.bg = normal_float.bg or normal.bg
    vim.api.nvim_set_hl(0, "NormalFloat", normal_float)

    float_border.fg = float_border.fg or non_text.fg or normal.fg
    float_border.bg = normal_float.bg
    vim.api.nvim_set_hl(0, "FloatBorder", float_border)

    float_title.fg = float_title.fg or get_hl("Title").fg or float_border.fg
    float_title.bg = normal_float.bg
    float_title.bold = true
    vim.api.nvim_set_hl(0, "FloatTitle", float_title)

    -- Split boundaries should be visible, but quieter than the active float
    -- outline. This is especially important between sidebars and the editor.
    vim.api.nvim_set_hl(0, "WinSeparator", {
        fg = non_text.fg or float_border.fg,
        bg = normal.bg,
    })

    local links = {
        -- Noice/NUI floats inherit the active colorscheme.
        NoiceCmdlinePopup = "NormalFloat",
        NoiceCmdlinePopupBorder = "FloatBorder",
        NoiceCmdlinePopupTitle = "FloatTitle",
        NoiceCmdlinePrompt = "Title",
        NoiceCmdlineIcon = "Special",
        NoiceConfirm = "NormalFloat",
        NoiceConfirmBorder = "FloatBorder",
        NoicePopup = "NormalFloat",
        NoicePopupBorder = "FloatBorder",
        NoicePopupmenu = "Pmenu",
        NoicePopupmenuBorder = "FloatBorder",
        NoicePopupmenuMatch = "Special",
        NoicePopupmenuSelected = "PmenuSel",
        NoiceSplitBorder = "WinSeparator",
        NeoTreeNormal = "Normal",
        NeoTreeNormalNC = "NormalNC",
        NeoTreeFloatNormal = "NormalFloat",
        NeoTreeDirectoryName = "Directory",
        NeoTreeDirectoryIcon = "Directory",
        NeoTreeCursorLine = "CursorLine",
        NeoTreeEndOfBuffer = "EndOfBuffer",
        NeoTreeIndentMarker = "NonText",
        NeoTreeFloatBorder = "FloatBorder",
        NeoTreeFloatTitle = "FloatTitle",
        NeoTreeWinSeparator = "WinSeparator",
        NeoTreeVertSplit = "WinSeparator",
        AvanteConflictCurrent = "DiffText",
        AvanteConflictCurrentLabel = "DiffText",
        AvanteConflictIncoming = "DiffAdd",
        AvanteConflictIncomingLabel = "DiffAdd",
        NotifyBackground = "NormalFloat",
        NotifyERRORBody = "NormalFloat",
        NotifyWARNBody = "NormalFloat",
        NotifyINFOBody = "NormalFloat",
        NotifyDEBUGBody = "NormalFloat",
        NotifyTRACEBody = "NormalFloat",

        -- Telescope.
        TelescopeNormal = "NormalFloat",
        TelescopeBorder = "FloatBorder",
        TelescopePromptNormal = "NormalFloat",
        TelescopePromptBorder = "FloatBorder",
        TelescopePromptTitle = "FloatTitle",
        TelescopePreviewNormal = "NormalFloat",
        TelescopePreviewBorder = "FloatBorder",
        TelescopePreviewTitle = "FloatTitle",
        TelescopeResultsNormal = "NormalFloat",
        TelescopeResultsBorder = "FloatBorder",
        TelescopeResultsTitle = "FloatTitle",
        TelescopeSelection = "PmenuSel",
        TelescopeMatching = "Special",
        TelescopePromptPrefix = "Special",
        TelescopeSelectionCaret = "Special",
        TelescopePreviewLine = "PmenuSel",
        TelescopePreviewMatch = "Search",

        -- FzfLua uses these groups for its main window, preview and border.
        FzfLuaNormal = "NormalFloat",
        FzfLuaBorder = "FloatBorder",
        FzfLuaTitle = "FloatTitle",
        FzfLuaPreviewNormal = "NormalFloat",
        FzfLuaPreviewBorder = "FloatBorder",
        FzfLuaPreviewTitle = "FloatTitle",
        FzfLuaCursorLine = "PmenuSel",
        FzfLuaSearch = "Search",
        FzfLuaFzfNormal = "NormalFloat",
        FzfLuaFzfCursorLine = "PmenuSel",
        FzfLuaFzfMatch = "Special",
        FzfLuaFzfBorder = "FloatBorder",
        FzfLuaFzfSeparator = "FloatBorder",
        FzfLuaFzfGutter = "NormalFloat",
        FzfLuaFzfPrompt = "Special",
        FzfLuaFzfPointer = "Special",

        -- Completion, documentation and signature-help windows.
        BlinkCmpMenu = "Pmenu",
        BlinkCmpMenuBorder = "FloatBorder",
        BlinkCmpMenuSelection = "PmenuSel",
        BlinkCmpDoc = "NormalFloat",
        BlinkCmpDocBorder = "FloatBorder",
        BlinkCmpDocSeparator = "FloatBorder",
        BlinkCmpDocCursorLine = "PmenuSel",
        BlinkCmpSignatureHelp = "NormalFloat",
        BlinkCmpSignatureHelpBorder = "FloatBorder",
        BlinkCmpLabelMatch = "Special",
        BlinkCmpScrollBarGutter = "PmenuSbar",
        BlinkCmpScrollBarThumb = "PmenuThumb",

        -- WhichKey and Snacks pickers use the same surface hierarchy.
        WhichKeyNormal = "NormalFloat",
        WhichKeyBorder = "FloatBorder",
        WhichKeyTitle = "FloatTitle",
        WhichKeySeparator = "NonText",
        SnacksPicker = "NormalFloat",
        SnacksPickerBorder = "FloatBorder",
        SnacksPickerTitle = "FloatTitle",
        SnacksPickerBox = "NormalFloat",
        SnacksPickerBoxBorder = "FloatBorder",
        SnacksPickerInput = "NormalFloat",
        SnacksPickerInputBorder = "FloatBorder",
        SnacksPickerList = "NormalFloat",
        SnacksPickerListBorder = "FloatBorder",
        SnacksPickerListCursorLine = "PmenuSel",
        SnacksPickerPreview = "NormalFloat",
        SnacksPickerPreviewBorder = "FloatBorder",
        SnacksPickerPreviewCursorLine = "CursorLine",

        -- Remaining floating and split-based plugin surfaces.
        LazyNormal = "NormalFloat",
        MasonNormal = "NormalFloat",
        DapUIFloatNormal = "NormalFloat",
        DapUIFloatBorder = "FloatBorder",
        NeotestBorder = "FloatBorder",
        NeotestFocused = "PmenuSel",
        NeotestFile = "Directory",
        NeotestDir = "Directory",
        NeotestIndent = "NonText",
        NeotestPassed = "DiagnosticOk",
        NeotestFailed = "DiagnosticError",
        NeotestRunning = "DiagnosticWarn",
        NeotestSkipped = "DiagnosticInfo",
        TroubleNormal = "NormalFloat",
        TroubleNormalNC = "NormalFloat",

        -- Avante defines hard-coded fallback colors. Pre-defining its shell
        -- groups keeps the sidebar and prompt tied to the active colorscheme.
        AvantePopupHint = "NormalFloat",
        AvanteSuggestion = "Comment",
        AvanteAnnotation = "Comment",
        AvanteInlineHint = "Keyword",
        AvanteToBeDeleted = "DiffDelete",
        AvanteToBeDeletedWOStrikethrough = "DiffDelete",
        AvanteCommentFg = "Comment",
        AvantePromptInput = "NormalFloat",
        AvantePromptInputBorder = "FloatBorder",
        AvanteSidebarNormal = "NormalFloat",
        AvanteSidebarWinSeparator = "WinSeparator",
        AvanteSidebarWinHorizontalSeparator = "WinSeparator",
        AvanteTaskRunning = "DiagnosticWarn",
        AvanteTaskCompleted = "DiagnosticOk",
        AvanteTaskFailed = "DiagnosticError",
        AvanteThinking = "DiagnosticHint",
    }

    for group, link in pairs(links) do
        vim.api.nvim_set_hl(0, group, { link = link })
    end

    local pmenu = get_hl("Pmenu")
    local pmenu_sel = get_hl("PmenuSel")

    pmenu.fg = pmenu.fg or normal_float.fg
    pmenu.bg = pmenu.bg or normal_float.bg
    pmenu.blend = 0
    vim.api.nvim_set_hl(0, "Pmenu", pmenu)

    if not pmenu_sel.bg then
        local selection = get_hl("CursorLine")
        if not selection.bg then
            selection = get_hl("Visual")
        end
        pmenu_sel.bg = selection.bg
    end
    pmenu_sel.fg = pmenu_sel.fg or normal.fg or pmenu.fg
    pmenu_sel.blend = 0
    vim.api.nvim_set_hl(0, "PmenuSel", pmenu_sel)

    local severity = {
        ERROR = "DiagnosticError",
        WARN = "DiagnosticWarn",
        INFO = "DiagnosticInfo",
        DEBUG = "DiagnosticHint",
        TRACE = "Special",
    }
    for level, target in pairs(severity) do
        local accent = get_hl(target).fg or float_border.fg
        vim.api.nvim_set_hl(0, "Notify" .. level .. "Border", { fg = accent, bg = normal_float.bg })
        vim.api.nvim_set_hl(0, "Notify" .. level .. "Icon", { fg = accent, bg = normal_float.bg })
        vim.api.nvim_set_hl(0, "Notify" .. level .. "Title", {
            fg = accent,
            bg = normal_float.bg,
            bold = true,
        })
    end

    local search_accent = get_hl("DiagnosticWarn").fg or float_border.fg
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", {
        fg = search_accent,
        bg = normal_float.bg,
    })

    -- Avante ships OneDark fallback colors. Define its color blocks from
    -- semantic colorscheme groups before the plugin loads, so buttons,
    -- headers and activity states match every supported theme.
    local avante_blocks = {
        AvanteTitle = "DiagnosticOk",
        AvanteSubtitle = "DiagnosticInfo",
        AvanteThirdTitle = "DiagnosticHint",
        AvanteConfirmTitle = "DiagnosticError",
        AvanteButtonDefault = "Comment",
        AvanteButtonDefaultHover = "DiagnosticHint",
        AvanteButtonPrimary = "DiagnosticInfo",
        AvanteButtonPrimaryHover = "Special",
        AvanteButtonDanger = "DiagnosticWarn",
        AvanteButtonDangerHover = "DiagnosticError",
        AvanteStateSpinnerGenerating = "Special",
        AvanteStateSpinnerToolCalling = "DiagnosticInfo",
        AvanteStateSpinnerFailed = "DiagnosticError",
        AvanteStateSpinnerSucceeded = "DiagnosticOk",
        AvanteStateSpinnerSearching = "DiagnosticHint",
        AvanteStateSpinnerThinking = "DiagnosticHint",
        AvanteStateSpinnerCompacting = "DiagnosticHint",
    }
    for group, target in pairs(avante_blocks) do
        local accent = get_hl(target).fg or float_title.fg
        vim.api.nvim_set_hl(0, group, {
            fg = normal.bg or normal_float.bg,
            bg = accent,
            bold = true,
        })
    end

    local avante_reversed = {
        AvanteReversedTitle = "DiagnosticOk",
        AvanteReversedSubtitle = "DiagnosticInfo",
        AvanteReversedThirdTitle = "DiagnosticHint",
    }
    for group, target in pairs(avante_reversed) do
        vim.api.nvim_set_hl(0, group, {
            fg = get_hl(target).fg or float_title.fg,
            bg = normal_float.bg,
        })
    end

    local logo_colors = {
        normal_float.fg or normal.fg,
        get_hl("Comment").fg or normal.fg,
        non_text.fg or float_border.fg,
    }
    for index = 1, 14 do
        local color_index = index <= 4 and 1 or (index <= 9 and 2 or 3)
        vim.api.nvim_set_hl(0, "AvanteLogoLine" .. index, { fg = logo_colors[color_index] })
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("SungpThemeUI", { clear = true }),
    callback = function()
        if M.loading then
            return
        end
        vim.schedule(M.apply_ui_highlights)
    end,
})

function M.load()
    M.loading = true
    vim.cmd.colorscheme(M.name)
    M.loading = false
    M.apply_ui_highlights()
end

return M
