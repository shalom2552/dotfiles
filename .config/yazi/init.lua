
require("git"):setup()
require("full-border"):setup()

-- status lines style (top and bottom)
require("yatline"):setup({
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },
	style_a = {
		fg = "#1e1e2e",
		bg_mode = { normal = "#89b4fa", select = "#cba6f7", un_set = "#f38ba8", },
	},
	style_b = { bg = "#313244", fg = "#cdd6f4" },
	style_c = { bg = "reset",   fg = "#bac2de" }, -- "reset" leaves it transparent
})

-- TODO: remove once yatline stops calling File:icon() (imsi32/yatline.yazi#79).
-- Check: after `ya pkg upgrade`, `grep -n ':icon(' ~/.config/yazi/plugins/yatline.yazi/main.lua` prints nothing.
function Yatline.string.get:hovered_file_extension(show_icon)
	local hovered = cx.active.current.hovered
	if not hovered then return "" end
	local name = hovered.cha.is_dir and "dir" or (hovered.url.name:match("^.+%.(.+)$") or "null")
	if not show_icon then return name end
	local icon = th.icon:match(hovered)
	return (icon and icon.text or "") .. " " .. name
end
