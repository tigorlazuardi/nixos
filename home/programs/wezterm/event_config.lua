local wezterm = require('wezterm')

local process_icons = {
	['docker'] = wezterm.nerdfonts.linux_docker,
	['docker-compose'] = wezterm.nerdfonts.linux_docker,
	['btm'] = '',
	['psql'] = '󱤢',
	['usql'] = '󱤢',
	['kuberlr'] = wezterm.nerdfonts.linux_docker,
	['ssh'] = wezterm.nerdfonts.fa_exchange,
	['ssh-add'] = wezterm.nerdfonts.fa_exchange,
	['kubectl'] = wezterm.nerdfonts.linux_docker,
	['stern'] = wezterm.nerdfonts.linux_docker,
	['nvim'] = wezterm.nerdfonts.custom_vim,
	['make'] = wezterm.nerdfonts.seti_makefile,
	['vim'] = wezterm.nerdfonts.dev_vim,
	['node'] = wezterm.nerdfonts.mdi_hexagon,
	['go'] = wezterm.nerdfonts.seti_go,
	['python3'] = '',
	['zsh'] = wezterm.nerdfonts.dev_terminal,
	['bash'] = wezterm.nerdfonts.cod_terminal_bash,
	['htop'] = wezterm.nerdfonts.mdi_chart_donut_variant,
	['cargo'] = wezterm.nerdfonts.dev_rust,
	['sudo'] = wezterm.nerdfonts.fa_hashtag,
	['lazydocker'] = wezterm.nerdfonts.linux_docker,
	['git'] = wezterm.nerdfonts.dev_git,
	['lua'] = wezterm.nerdfonts.seti_lua,
	['wget'] = wezterm.nerdfonts.mdi_arrow_down_box,
	['curl'] = wezterm.nerdfonts.mdi_flattr,
	['gh'] = wezterm.nerdfonts.dev_github_badge,
	['ruby'] = wezterm.nerdfonts.cod_ruby,
}

local function get_current_working_dir(tab)
	local current_dir = tab.active_pane
			and tab.active_pane.current_working_dir
			and tab.active_pane.current_working_dir()
		or { file_path = '' }
	local HOME_DIR = os.getenv('HOME')

	return current_dir.file_path == HOME_DIR and '~' or string.gsub(current_dir.file_path, '(.*[/\\])(.*)', '%2')
end

local function get_process(tab)
	if not tab.active_pane or tab.active_pane.foreground_process_name == '' then
		return nil
	end

	local process_name = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
	if string.find(process_name, 'kubectl') then
		process_name = 'kubectl'
	end

	return process_icons[process_name] or string.format('[%s]', process_name)
end

wezterm.on('format-window-title', function(tab, tabs, panes, config)
	local cwd = wezterm.format({
		{ Text = get_current_working_dir(tab) },
	})

	local process = get_process(tab)
	local title = process and string.format(' %s (%s) ', process, cwd) or ' [?] '
	return title
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
	local has_unseen_output = false
	if not tab.is_active then
		for _, pane in ipairs(tab.panes) do
			if pane.has_unseen_output then
				has_unseen_output = true
				break
			end
		end
	end

	local cwd = wezterm.format({
		{ Text = get_current_working_dir(tab) },
	})

	local process = get_process(tab)
	local title = process and string.format(' %s (%s) ', process, cwd) or ' [?] '

	if has_unseen_output then
		return {
			{ Foreground = { Color = '#28719c' } },
			{ Text = title },
		}
	end

	return {
		{ Text = title },
	}
end)

local state = {
	debug_mode = false,
}

wezterm.on('update-right-status', function(window, pane)
	local process = ''

	if state.debug_mode then
		local info = pane:get_foreground_process_info()
		if info then
			process = info.name
			for i = 2, #info.argv do
				process = info.argv[i]
			end
		end
	end

	local status = (#process > 0 and ' | ' or '')
	local name = window:active_key_table()
	if name then
		status = string.format('󰌌  { %s }', name)
	end

	if window:get_dimensions().is_full_screen then
		status = status .. wezterm.strftime(' %R ')
	end

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = '#7eb282' } },
		{ Text = process },
		{ Foreground = { Color = '#808080' } },
		{ Text = status },
	}))
end)
