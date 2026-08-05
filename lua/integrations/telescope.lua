local telescope = require("telescope")

telescope.setup({
    defaults = {
        border = true,
        winblend = 0,
        prompt_prefix = "    ",
        selection_caret = "   ",
        entry_prefix = "    ",
        file_ignore_patterns = { "%.git/" },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            width = 0.86,
            height = 0.78,
            prompt_position = "top",
            horizontal = {
                preview_width = 0.52,
            },
            vertical = {
                mirror = true,
            },
        },
        path_display = { "smart" },
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
