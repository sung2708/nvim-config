local M = require("helper.utils")

M.on_plugin_load("telescope.nvim", "telescope", function(telescope)
    telescope.setup({
        defaults = {
            file_ignore_patterns = { "%.git/" },
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--glob",
                "!.git/*",
            },
        },
        pickers = {
            find_files = {
                find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
            ["ui-select"] = {
                require("telescope.themes").get_dropdown({}),
            },
            file_browser = {
                hijack_netrw = true,
            },
        },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "file_browser")
    pcall(telescope.load_extension, "ui-select")
end)
