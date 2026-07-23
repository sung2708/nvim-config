local neotree = require("neo-tree")

neotree.setup({
    close_if_last_window = true,
    filesystem = {
        filtered_items = { visible = true, hide_dotfiles = false },
        follow_current_file = { enabled = true },
    },
})
