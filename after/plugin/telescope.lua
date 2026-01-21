local M = require("helper.utils")

local telescope = M.safe_require("telescope")
if telescope then
telescope.setup({
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
    }
  },
})
end
pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "file_browser")
pcall(telescope.load_extension, "ui-select")
