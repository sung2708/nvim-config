local codex_sqlite_home = vim.fs.joinpath(vim.fn.stdpath("config"), ".nvim-data", "codex-sqlite")

local codex_config_path = vim.fs.joinpath(vim.fn.expand("~"), ".codex", "config.toml")

local function save_codex_default_model(model)
    if not model or model == "" or model:find("[\r\n]") or model:find('"') then
        return false, "invalid model name"
    end

    vim.fn.mkdir(vim.fs.dirname(codex_config_path), "p")
    local lines = vim.fn.filereadable(codex_config_path) == 1 and vim.fn.readfile(codex_config_path) or {}
    local replaced = false
    local insert_at = #lines + 1
    for index, line in ipairs(lines) do
        if line:match("^%s*%[") then
            insert_at = index
            break
        end
        if line:match("^%s*model%s*=") then
            lines[index] = 'model = "' .. model .. '"'
            replaced = true
            break
        end
    end
    if not replaced then
        table.insert(lines, insert_at, 'model = "' .. model .. '"')
    end

    local ok = vim.fn.writefile(lines, codex_config_path) == 0
    return ok, ok and nil or "could not write " .. codex_config_path
end

local function install_avante_sidebar_guards()
    local sidebar = require("avante.sidebar")
    if sidebar._codex_sidebar_guards_installed then
        return
    end

    local original_get_tool_use_uuid = sidebar.get_current_tool_use_message_uuid
    sidebar.get_current_tool_use_message_uuid = function(self, ...)
        local result = self.containers and self.containers.result
        if not result or not result.winid or not vim.api.nvim_win_is_valid(result.winid) then
            return nil
        end
        return original_get_tool_use_uuid(self, ...)
    end

    local original_render_tool_use_buttons = sidebar.render_tool_use_control_buttons
    sidebar.render_tool_use_control_buttons = function(self, ...)
        local result = self.containers and self.containers.result
        if not result or not result.bufnr or not vim.api.nvim_buf_is_valid(result.bufnr) then
            return
        end
        return original_render_tool_use_buttons(self, ...)
    end

    sidebar._codex_sidebar_guards_installed = true
end

local function select_acp_config(category, prompt)
    local api = require("avante.api")
    local opened_for_selector = false

    local function get_ready_sidebar()
        local sidebar = require("avante").get(false)
        if
            sidebar
            and sidebar:is_open()
            and sidebar.containers
            and sidebar.containers.input
            and sidebar.containers.result
        then
            return sidebar
        end
        return nil
    end

    local function show_selector(sidebar)
        local client = sidebar.acp_client
        local config
        for _, option in ipairs(client.config_options or {}) do
            if option.category == category then
                config = option
                break
            end
        end

        if not config or not config.options or #config.options == 0 then
            vim.notify("Codex ACP does not provide " .. category .. " options", vim.log.levels.WARN)
            return
        end

        if opened_for_selector and sidebar:is_open() then
            sidebar:close()
            vim.cmd("stopinsert")
        end

        vim.ui.select(config.options, {
            prompt = prompt,
            format_item = function(item)
                local selected = item.value == config.currentValue and "* " or "  "
                local description = item.description and (" - " .. item.description) or ""
                return selected .. (item.name or item.value) .. description
            end,
        }, function(choice)
            if not choice then
                return
            end

            local session_id = sidebar.chat_history and sidebar.chat_history.acp_session_id
            if not session_id then
                vim.notify("Codex ACP session is not ready", vim.log.levels.WARN)
                return
            end

            local function done(_, err)
                vim.schedule(function()
                    if err then
                        vim.notify(
                            "Failed to update " .. config.name .. ": " .. (err.message or tostring(err)),
                            vim.log.levels.ERROR
                        )
                        return
                    end
                    vim.notify(config.name .. ": " .. (choice.name or choice.value), vim.log.levels.INFO)
                    if category == "model" then
                        local saved, save_err = save_codex_default_model(choice.value)
                        if not saved then
                            vim.notify(
                                "Session model changed, but default was not saved: " .. save_err,
                                vim.log.levels.WARN
                            )
                        else
                            vim.notify("Codex default model saved: " .. choice.value, vim.log.levels.INFO)
                        end
                    end
                    if sidebar:is_open() and sidebar.containers and sidebar.containers.result then
                        pcall(sidebar.render_result, sidebar)
                    end
                end)
            end

            if client._legacy_api and config.id == "mode" then
                client:set_mode(session_id, choice.value, done)
            elseif client._legacy_api and config.id == "model" then
                client:set_model(session_id, choice.value, done)
            else
                client:set_config_option(session_id, config.id, choice.value, done)
            end
        end)
    end

    local attempts = 0
    local session_started = false
    local function wait_for_options()
        attempts = attempts + 1
        local sidebar = get_ready_sidebar()

        if sidebar and sidebar.acp_client and sidebar.acp_client.config_options then
            show_selector(sidebar)
            return
        end

        if sidebar and not session_started then
            session_started = true
            local ok, err = pcall(sidebar.handle_submit, sidebar, "")
            if not ok then
                vim.notify("Could not initialize Codex ACP: " .. tostring(err), vim.log.levels.ERROR)
                return
            end
        end

        if attempts < 150 then
            vim.defer_fn(wait_for_options, 100)
            return
        end

        vim.notify("Timed out waiting for Codex ACP. Check :messages for details.", vim.log.levels.WARN)
    end

    if not get_ready_sidebar() then
        opened_for_selector = true
        api.ask()
    end
    vim.defer_fn(wait_for_options, 100)
end

return {
    {
        "yetone/avante.nvim",
        version = false,
        build = vim.fn.has("win32") ~= 0
                and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            or "make",
        cmd = {
            "AvanteAsk",
            "AvanteBuild",
            "AvanteChat",
            "AvanteChatNew",
            "AvanteClear",
            "AvanteEdit",
            "AvanteFocus",
            "AvanteHistory",
            "AvanteRefresh",
            "AvanteStop",
            "AvanteSwitchProvider",
            "AvanteToggle",
            "AvanteCodexDefaultModel",
        },
        keys = {
            {
                "<leader>a?",
                function()
                    require("avante.api").select_model()
                end,
                desc = "Avante: Select Model",
            },
            {
                "<leader>aB",
                function()
                    require("avante.api").add_buffer_files()
                end,
                desc = "Avante: Add All Buffers",
            },
            {
                "<leader>aC",
                function()
                    require("avante").toggle.selection()
                end,
                desc = "Avante: Toggle Selection",
            },
            {
                "<leader>aE",
                function()
                    select_acp_config("thought_level", "Codex reasoning effort> ")
                end,
                desc = "Avante: Select Reasoning Effort",
            },
            {
                "<leader>aM",
                function()
                    select_acp_config("model", "Codex model> ")
                end,
                desc = "Avante: Select ACP Model",
            },
            {
                "<leader>aD",
                function()
                    select_acp_config("model", "Codex default model> ")
                end,
                desc = "Avante: Save Default Model",
            },
            {
                "<leader>aR",
                function()
                    require("avante.repo_map").show()
                end,
                desc = "Avante: Show Repo Map",
            },
            {
                "<leader>aS",
                function()
                    require("avante.api").stop()
                end,
                desc = "Avante: Stop",
            },
            {
                "<leader>ai",
                function()
                    require("avante.api").ask()
                end,
                mode = { "n", "v" },
                desc = "Avante: Ask",
            },
            {
                "<leader>ad",
                function()
                    require("avante").toggle.debug()
                end,
                desc = "Avante: Toggle Debug",
            },
            {
                "<leader>ae",
                function()
                    require("avante.api").edit()
                end,
                mode = "v",
                desc = "Avante: Edit Selection",
            },
            {
                "<leader>af",
                function()
                    require("avante.api").focus()
                end,
                desc = "Avante: Focus Sidebar",
            },
            {
                "<leader>ah",
                function()
                    require("avante.api").select_history()
                end,
                desc = "Avante: History",
            },
            {
                "<leader>am",
                function()
                    select_acp_config("mode", "Codex mode> ")
                end,
                desc = "Avante: Select ACP Mode",
            },
            {
                "<leader>an",
                function()
                    require("avante.api").ask({ new_chat = true })
                end,
                mode = { "n", "v" },
                desc = "Avante: New Ask",
            },
            {
                "<leader>ar",
                function()
                    require("avante.api").refresh()
                end,
                desc = "Avante: Refresh",
            },
            {
                "<leader>as",
                function()
                    require("avante").toggle.suggestion()
                end,
                desc = "Avante: Toggle Suggestions",
            },
            {
                "<leader>at",
                function()
                    require("avante").toggle()
                end,
                desc = "Avante: Toggle Sidebar",
            },
            {
                "<leader>az",
                function()
                    require("avante.api").zen_mode()
                end,
                mode = { "n", "v" },
                desc = "Avante: Toggle Zen Mode",
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "folke/snacks.nvim",
            "ibhagwan/fzf-lua",
            {
                "HakonHarnes/img-clip.nvim",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true,
                    },
                },
            },
        },
        config = function(_, opts)
            vim.fn.mkdir(codex_sqlite_home, "p")
            require("avante").setup(opts)
            install_avante_sidebar_guards()
            vim.api.nvim_create_user_command("AvanteCodexDefaultModel", function()
                select_acp_config("model", "Codex default model> ")
            end, { desc = "Select and save Codex default model" })
        end,
        opts = {
            provider = "codex",
            mode = "agentic",
            log_level = vim.log.levels.OFF,
            instructions_file = "avante.md",
            acp_providers = {
                codex = {
                    command = vim.fn.has("win32") ~= 0 and "cmd.exe" or "codex-acp",
                    args = vim.fn.has("win32") ~= 0 and { "/d", "/s", "/c", "codex-acp" } or {},
                    env = {
                        NODE_NO_WARNINGS = "1",
                        -- Keep auth/config in the user's default ~/.codex, but do
                        -- not share Codex Desktop's live SQLite files with ACP.
                        CODEX_SQLITE_HOME = codex_sqlite_home,
                    },
                },
            },
            input = {
                provider = "snacks",
                provider_opts = {
                    title = "Avante",
                    icon = " ",
                },
            },
            history = {
                storage_path = vim.fs.joinpath(vim.fn.stdpath("config"), ".nvim-data", "avante"),
            },
            selector = {
                provider = "fzf_lua",
            },
            mappings = {
                ask = "<leader>ai",
            },
            highlights = {
                diff = {
                    current = "DiffText",
                    incoming = "DiffAdd",
                },
            },
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = true,
                minimize_diff = true,
                enable_token_counting = true,
                auto_add_current_file = true,
                auto_approve_tool_permissions = false,
                confirmation_ui_style = "inline_buttons",
                acp_follow_agent_locations = true,
            },
            windows = {
                position = "right",
                wrap = true,
                width = 42,
                input = {
                    prefix = "  ",
                    height = 8,
                },
                ask = {
                    start_insert = true,
                    border = "rounded",
                    focus_on_apply = "ours",
                },
                sidebar_header = {
                    enabled = true,
                    align = "center",
                    rounded = true,
                    include_model = true,
                },
            },
        },
    },
}
