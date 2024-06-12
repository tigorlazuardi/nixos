require("mini.base16").setup({
	palette = {
		base00 = "{{color0}}", -- Background
		base01 = "{{color1 | darken(0.75)}}", -- CursorLine, CMP Background
		base02 = "{{color2 | darken(0.50)}}", -- Visual Select
		base03 = "{{color3 | blend(color1)}}", -- Comment, MatchParen
		base04 = "{{color4}}", -- Keywords, properties, Line Number
		base05 = "{{color5}}", -- NormalText, CMP Selection, TSProperty
		base06 = "{{color6}}",
		base07 = "{{color7}}",
		base08 = "{{color8 | complementary}}", -- TSVariable
		base09 = "{{color9 | complementary | lighten(0.25)}}", -- TSConstant, @constant (booleans, etc)
		base0A = "{{color10 | complementary | lighten(0.25)}}", -- CMP Property (Field), TSType
		base0B = "{{color11 | blend(color7) | complementary | lighten(0.25)}}", -- String Texts
		base0C = "{{color12}}", -- Types, Regex
		base0D = "{{color13}}", -- Functions, String Escape
		base0E = "{{color14}}",
		base0F = "{{color15}}",
	},
	use_cterm = vim.fn.has("termguicolors") == 0,
	plugins = { default = true },
})

------- Neovide Configuration -------

-- stylua: ignore start
vim.g.neovide_transparency = {{alpha/100}}
-- stylua: ignore end

vim.g.neovide_background_color = "{{color0}}{{ alpha | alpha_hexa }}"
