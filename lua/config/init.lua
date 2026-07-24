vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.copilot_enabled = true

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lazy")
