local function build_fzf_native(plugin)
    local command = { "make" }
    local build_dir = plugin.dir .. "/build"

    if vim.fn.isdirectory(build_dir) == 1 then
        vim.fn.delete(build_dir, "rf")
    end

    if vim.fn.has("win32") == 1 and vim.fn.executable("zig") == 1 then
        command[#command + 1] = "CC=zig cc"
    end

    local result = vim.system(command, {
        cwd = plugin.dir,
        text = true,
    }):wait()

    if result.code ~= 0 then
        error(result.stderr ~= "" and result.stderr or result.stdout)
    end
end

local function has_executable(commands)
    for _, command in ipairs(commands) do
        if vim.fn.executable(command) == 1 then
            return true
        end
    end
    return false
end

local has_configured_compiler = vim.env.CC and vim.env.CC ~= ""
local can_build_fzf_native = vim.fn.executable("make") == 1
    and (has_configured_compiler or has_executable({ "zig", "cc", "clang", "gcc" }))

return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        keys = {
            {
                "<leader>ff",
                function()
                    require("telescope.builtin").find_files()
                end,
                desc = "Find: Files (Telescope)",
            },
            {
                "<leader>fg",
                function()
                    require("telescope.builtin").live_grep()
                end,
                desc = "Find: Grep (Telescope)",
            },
            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers()
                end,
                desc = "Find: Buffers (Telescope)",
            },
            {
                "<leader>fh",
                function()
                    require("telescope.builtin").help_tags()
                end,
                desc = "Find: Help (Telescope)",
            },
            {
                "<leader>fe",
                function()
                    require("telescope").extensions.file_browser.file_browser({
                        path = vim.fn.expand("%:p:h"),
                        select_buffer = true,
                    })
                end,
                desc = "Find: File Browser",
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                enabled = can_build_fzf_native,
                build = build_fzf_native,
            },
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            require("integrations.telescope")
        end,
    },
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            {
                "<leader>fF",
                function()
                    require("fzf-lua").files()
                end,
                desc = "Find: Fast Files (Fzf)",
            },
            {
                "<leader>fG",
                function()
                    require("fzf-lua").live_grep()
                end,
                desc = "Find: Fast Grep (Fzf)",
            },
            {
                "<leader>fB",
                function()
                    require("fzf-lua").buffers()
                end,
                desc = "Find: Fast Buffers (Fzf)",
            },
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("integrations.fzf")
        end,
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar", "GrugFarWithin" },
        keys = {
            {
                "<leader>fr",
                function()
                    require("grug-far").open()
                end,
                desc = "Find: Search and Replace",
            },
            {
                "<leader>fr",
                function()
                    require("grug-far").open({
                        visualSelectionUsage = "auto-detect",
                    })
                end,
                mode = "x",
                desc = "Find: Replace Selection",
            },
        },
        opts = {
            headerMaxWidth = 80,
        },
    },
}
