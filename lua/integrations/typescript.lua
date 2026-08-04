require("typescript-tools").setup({
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    settings = {
        separate_diagnostic_server = false,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = "all",
        complete_function_calls = true,
        tsserver_file_preferences = {
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
        },
    },
})

-- The plugin normally defines these from its ftplugin. Since this setup is
-- deliberately deferred until after the first FileType event, register them
-- explicitly so the first TypeScript/JavaScript buffer is fully functional.
require("typescript-tools.user_commands").setup_user_commands()
