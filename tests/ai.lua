vim.opt.rtp:prepend(vim.fn.getcwd())
local has = vim.fn.has
local key = vim.env.EXA_API_KEY
local function specs(value, windows)
    vim.env.EXA_API_KEY = value
    vim.fn.has = function(name)
        if name == "win32" then
            return windows and 1 or 0
        end
        return has(name)
    end
    package.loaded["plugins.ai"] = nil
    local result = require("plugins.ai")
    vim.fn.has = has
    return result
end
local missing = specs(nil, false)
assert(#missing[1].opts.mcp.opts.default_servers == 0, "Exa started without credentials")
local configured = specs("test-fixture", true)
assert(configured[1].opts.mcp.opts.default_servers[1] == "exa")
assert(configured[1].opts.mcp.servers.exa.cmd[1] == "cmd.exe", "Windows cannot execute npx.cmd directly")
assert(configured[2].event == "InsertEnter", "Copilot starts before typing")
vim.env.EXA_API_KEY = key
print("PASS optional Exa credentials, Windows launch and deferred Copilot")

local source = vim.api.nvim_create_buf(true, false)
local created, connected, submitted, stopped = 0, false, 0, 0
local chat = {
    bufnr = source,
    adapter = { type = "acp" },
    acp_connection = {
        is_connected = function()
            return connected
        end,
    },
    submit = function()
        submitted = submitted + 1
    end,
    stop = function()
        stopped = stopped + 1
    end,
}
package.loaded["codecompanion"] = {
    chat = function(opts)
        created = created + 1
        opts.callbacks.on_created(chat)
        return chat
    end,
    last_chat = function()
        return chat
    end,
}
package.loaded["codecompanion.utils.context"] = {
    get = function()
        return { is_visual = true, code = "print(1)", filetype = "lua" }
    end,
}
package.loaded["nui.utils.autocmd"] = { event = { BufLeave = "BufLeave" } }
package.loaded["nui.input"] = function(_, opts)
    return {
        map = function() end,
        on = function() end,
        unmount = function() end,
        mount = function()
            opts.on_submit("explain")
        end,
    }
end
local actions = require("integrations.codecompanion")
actions.ask_selection()
assert(vim.wait(1000, function()
    return created == 1
end))
for _, mapping in ipairs(configured[1].keys) do
    if mapping[1] == "<leader>aS" then
        mapping[2]()
    end
end
connected = true
vim.wait(100)
assert(stopped == 1 and submitted == 0, "stopped chat still submitted when ACP connected")
actions.ask_selection()
assert(vim.wait(1000, function()
    return submitted == 1
end))
assert(created == 2)
print("PASS Stop cancels a queued ACP prompt; a new prompt still submits")
