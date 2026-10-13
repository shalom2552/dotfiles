
require("git"):setup()
require("full-border"):setup()

-- status lines style (top and bottom)
require("yatline"):setup({
    section_separator = { open = "", close = "" },
    part_separator = { open = "", close = "" },
    inverse_separator = { open = "", close = "" },
    style_a = {
        fg = "#45475a",
        bg_mode = { normal = "#89b4fa", select = "#cba6f7", un_set = "#f38ba8", },
    },
    style_b = { bg = "#313244", fg = "#89b4fa" },
    style_c = { bg = "reset",   fg = "#89b4fa" }, -- "reset" leaves it transparent

    status_line = {
        left = {
            section_a = { { type = "string", name = "tab_mode" } },
            section_b = { { type = "string", name = "hovered_size" } },
            section_c = {
                { type = "string", name = "hovered_path" },
            },
        },
        right = {
            section_a = { { type = "string", name = "cursor_position" } },
            section_b = { { type = "string", name = "cursor_percentage" } },
            section_c = {
                { type = "coloreds", name = "count", params = { false, true } },
                -- { type = "string", name = "hovered_file_extension", params = { "count" } },
            },
        },
    },
})

