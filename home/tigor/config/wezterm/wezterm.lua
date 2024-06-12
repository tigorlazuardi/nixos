local wezterm = require('wezterm')

local shortcuts = require('keys')

return {
	font = wezterm.font_with_fallback({
		-- 'Comic Code Ligatures',
		'JetBrainsMono Nerd Font Mono',
		'Noto Color Emoji',
		'Material Design Icons',
		'codicon',
		'monospace',
	}),
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	tab_max_width = 32,
	window_close_confirmation = 'NeverPrompt',
	color_scheme = 'Catppuccin Mocha',
	warn_about_missing_glyphs = false,
	check_for_updates = false,
	ssh_domains = {
		{
			name = 'home',
			remote_address = 'home',
			username = 'tigor',
			ssh_option = {
				identityfile = wezterm.home_dir .. '/.ssh/id_ed25519.pub',
			},
		},
	},
	unix_domains = {
		{
			name = 'unix',
		},
	},
	mouse_bindings = shortcuts.mouse_bindings,
	leader = shortcuts.leader,
	keys = shortcuts.keys,
	key_tables = shortcuts.key_tables,
	window_background_opacity = 1,
	text_background_opacity = 1,
	hyperlink_rules = {
		-- Linkify things that look like URLs and the host has a TLD name.
		-- Compiled-in default. Used if you don't specify any hyperlink_rules.
		{
			regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
			format = '$0',
		},

		-- linkify email addresses
		-- Compiled-in default. Used if you don't specify any hyperlink_rules.
		{
			regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
			format = 'mailto:$0',
		},

		-- file:// URI
		-- Compiled-in default. Used if you don't specify any hyperlink_rules.
		{
			regex = [[\bfile://\S*\b]],
			format = '$0',
		},

		-- filename:linenumber
		{
			regex = [[/.*:\d+]],
			format = '$0',
		},

		-- Linkify things that look like URLs with numeric addresses as hosts.
		-- E.g. http://127.0.0.1:8000 for a local development server,
		-- or http://192.168.1.1 for the web interface of many routers.
		{
			regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
			format = '$0',
		},
	},
}
