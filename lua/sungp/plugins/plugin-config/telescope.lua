local M = require("sungp.helper.utils")

return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
    },
        -- Basic search
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope: Find Files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope: Live Grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope: Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Telescope: Help Tags" },
        
        -- Advanced search
        { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Telescope: Word under cursor" },
        { "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Telescope: Fuzzy find in buffer" },
        { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Telescope: Recent Files" },
        
        -- Git
        { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git: Commits" },
        { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git: Status" },

        -- File Browser
        { "<leader>fe", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "Telescope: File Browser" },
        
        -- Utility shortcuts
        { "<esc>", "<cmd>noh<cr><esc>", mode = "n", silent = true, desc = "Clear search highlight" },
    },
    config = function()
        local telescope = M.safe_require("telescope")
        if not telescope then
            return
        end

        telescope.setup({
            defaults = {
                path_display = { "truncate " },
                mappings = {
                    i = {
                        ["<C-u>"] = false,
                        ["<C-d>"] = false,
                        -- Move faster in the results menu
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                ['ui-select'] = {
                    require("telescope.themes").get_dropdown {}
                },
                ['file_browser'] = {
                    hijack_netrw = true,
                    theme = "ivy", -- Displays the browser file at the bottom (ivy form) for easy visibility
                }
            },
        })
        
        -- Load extensions
        pcall(telescope.load_extension, "fzf")
        pcall(telescope.load_extension, "file_browser")
        pcall(telescope.load_extension, "ui-select")
    end,
}