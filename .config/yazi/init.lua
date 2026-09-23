th.git = th.git or {}
th.git.modified_sign  = "M "
th.git.added_sign     = "A "
th.git.deleted_sign   = "D "
th.git.untracked_sign = "? "
th.git.updated_sign   = "U "
th.git.ignored_sign   = "! "
th.git.clean_sign     = ""

require("git"):setup()

require("full-border"):setup()

require("yatline"):setup({
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },

	style_a = {
		fg = "#1a1b26",
		bg_mode = {
			normal = "#7aa2f7",
			select = "#bb9af7",
			un_set = "#f7768e",
		},
	},
	style_b = { bg = "#24283b", fg = "#c0caf5" },
	style_c = { bg = "reset",   fg = "#a9b1d6" }, -- "reset" leaves it transparent
})

