local M = {}

-- Chỉ cần đổi dòng này để chọn theme.
M.name = "catppuccin-frappe"

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

    -- Give every floating UI the editor's surface. NUI is used by Noice,
    -- Neo-tree and CodeCompanion, and some consumers use NormalFloat while
    -- others use Normal directly. Keeping NormalFloat on Normal's background
    -- removes a second, plugin-specific surface across all colorschemes.
    normal_float.fg = normal_float.fg or normal.fg
    normal_float.bg = normal.bg
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
        -- Noice's popup menus are NUI windows too. Keep their normal rows on
        -- the editor surface while retaining PmenuSel for the active row.
        NoicePopupmenu = "Normal",
        NoicePopupmenuBorder = "WinSeparator",
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
        NotifyBackground = "NormalFloat",
        NotifyERRORBody = "NormalFloat",
        NotifyWARNBody = "NormalFloat",
        NotifyINFOBody = "NormalFloat",
        NotifyDEBUGBody = "NormalFloat",
        NotifyTRACEBody = "NormalFloat",

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

        -- Breadcrumb bar and its symbol menus.
        DropBarCurrentContext = "PmenuSel",
        DropBarCurrentContextIcon = "PmenuSel",
        DropBarCurrentContextName = "PmenuSel",
        DropBarHover = "Visual",
        DropBarIconKindDefault = "Special",
        DropBarIconKindDefaultNC = "WinBarNC",
        DropBarIconUIIndicator = "SpecialChar",
        DropBarIconUIPickPivot = "DiagnosticError",
        DropBarIconUISeparator = "NonText",
        DropBarIconUISeparatorMenu = "NonText",
        DropBarMenuCurrentContext = "PmenuSel",
        DropBarMenuFloatBorder = "FloatBorder",
        DropBarMenuNormalFloat = "NormalFloat",
        DropBarMenuSbar = "PmenuSbar",
        DropBarMenuThumb = "PmenuThumb",
        DropBarPreview = "Visual",

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

        -- CodeCompanion uses semantic groups for chat, tools, and diffs.
        CodeCompanionChatError = "DiagnosticError",
        CodeCompanionChatFold = "Comment",
        CodeCompanionChatHeader = "Title",
        CodeCompanionChatInfo = "DiagnosticInfo",
        CodeCompanionChatSeparator = "WinSeparator",
        CodeCompanionChatSubtext = "Comment",
        CodeCompanionChatTokens = "Comment",
        CodeCompanionChatTool = "Special",
        CodeCompanionChatToolFailure = "DiagnosticError",
        CodeCompanionChatToolFailureIcon = "DiagnosticError",
        CodeCompanionChatToolGroup = "Constant",
        CodeCompanionChatToolInProgress = "DiagnosticInfo",
        CodeCompanionChatToolInProgressIcon = "DiagnosticInfo",
        CodeCompanionChatToolPending = "DiagnosticWarn",
        CodeCompanionChatToolPendingIcon = "DiagnosticWarn",
        CodeCompanionChatToolSuccess = "DiagnosticOk",
        CodeCompanionChatToolSuccessIcon = "DiagnosticOk",
        CodeCompanionChatToolText = "Comment",
        CodeCompanionChatEditorContext = "Identifier",
        CodeCompanionChatWarn = "DiagnosticWarn",
        CodeCompanionDiffAdd = "DiffAdd",
        CodeCompanionDiffDelete = "DiffDelete",
        CodeCompanionDiffText = "DiffText",
        CodeCompanionDiffTextDelete = "DiffDelete",
        CodeCompanionDiffBanner = "DiagnosticHint",
        CodeCompanionDiffBannerInline = "Comment",
        CodeCompanionCLIPath = "Include",
        CodeCompanionCodeReviewComment = "DiagnosticHint",
        CodeCompanionVirtualText = "Comment",
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
