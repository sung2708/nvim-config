local M = require("helper.utils")

M.on_plugin_load("neo-tree.nvim", "neo-tree", function(neotree)
    neotree.setup({
        close_if_last_window = true,
        filesystem = {
            filtered_items = { visible = true, hide_dotfiles = false },
            follow_current_file = { enabled = true },
        }
    })
end)

