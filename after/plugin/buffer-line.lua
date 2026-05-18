local M = require("helper.utils")
local bufferline = M.safe_require("bufferline")
if bufferline then
	bufferline.setup({
		options = {
            style_preset = bufferline.style_preset.no_italic,
            style_preset = {
                bufferline.style_preset.no_italic,
                bufferline.style_preset.no_bold
            },
            indicator = { icon = "▎", style = "icon" },
			buffer_close_icon = "󰅖",
			modified_icon = "●",
			close_icon = "",
			left_trunc_marker = "",
			right_trunc_marker = "",
            hover = {
                enabled = true,
                delay = 200,
                reveal = {'close'}
            },
			separator_style = "slope",
			always_show_bufferline = true,
            diagnostics = "coc", 
            numbers = "ordinal",
            diagnostics_indicator = function(count, level, diagnostics_dict, context)
                local s = " "
                for n, c in pairs(diagnostics_dict) do
                    local sym = n == "error" and " "
                        or (n == "warning" and " " or " ")
                    s = s .. c .. sym
                end
                return vim.trim(s)
            end,
            offsets = {
				{
					filetype = "neo-tree",
					text = "File Explorer",
					highlight = "Directory",
					separator = true,
					text_align = "center",
				},
            },
            groups = {
                items = {
                    require('bufferline.groups').builtin.pinned:with({ icon = "󰐃 " })
                }
            }
		},
	})
end