local neotree = require("neo-tree")

neotree.setup({
    close_if_last_window = true,
    popup_border_style = "rounded",
    default_component_configs = {
        indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "╰",
        },
    },
    filesystem = {
        filtered_items = { visible = true, hide_dotfiles = false },
        follow_current_file = { enabled = true },
    },
})
