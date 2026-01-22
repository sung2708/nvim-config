local M = require("sungp.helper.utils")

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local cmp_lsp = M.safe_require("cmp_nvim_lsp")
        if not cmp_lsp then return end
        local capabilities = cmp_lsp.default_capabilities()

        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }
                
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "LSP: Definition", buffer = ev.buf })
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "LSP: Declaration", buffer = ev.buf })
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "LSP: Implementation", buffer = ev.buf })
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "LSP: References", buffer = ev.buf })
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "LSP: Hover", buffer = ev.buf })
                
                -- Chỉnh sửa và Hành động
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "LSP: Rename", buffer = ev.buf })
                vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = "LSP: Code Action", buffer = ev.buf })
            end,
        })

        
        local servers = { "pyright", "ts_ls", "lua_ls", "gopls" }

        for _, name in ipairs(servers) do
            local config = vim.lsp.config[name]
            if config then
                config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities)

                if name == "pyright" then
                    config.settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "basic",
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "workspace",
                                autoImportCompletions = true,
                            },
                        },
                    }
                elseif name == "ts_ls" then
                    config.on_attach = function(client)
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end
                elseif name == "lua_ls" then
                    config.settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = { enable = false },
                        },
                    }
                elseif name == "gopls" then
                    config.settings = {
                        gopls = {
                            analyses = { unusedparams = true },
                            staticcheck = true,
                            completeUnimported = true,
                        },
                    }
                end

                vim.lsp.enable(name)
            end
        end
    end,
}