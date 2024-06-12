local wezterm = require('wezterm')
local act = wezterm.action

wezterm.on('update-status', function(window)
	local name = window:active_key_table()
	if name then
		name = 'TABLE: ' .. name
	end
	window:set_left_status(name or '')
end)

local M = {}

M.keys = {
	{
		key = ':',
		mods = 'LEADER|SHIFT',
		action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS|LAUNCH_MENU_ITEMS|DOMAINS' }),
	},
	{
		key = 'phys:Backspace',
		mods = 'LEADER',
		action = act.SplitPane({ direction = 'Down', size = { Percent = 25 } }),
	},
	{
		key = 'phys:Backspace',
		mods = 'LEADER|SHIFT',
		action = act.SplitPane({ direction = 'Down' }),
	},
	{
		key = 'Enter',
		mods = 'LEADER',
		action = act.SplitPane({ direction = 'Right', size = { Percent = 25 } }),
	},
	{
		key = 'Enter',
		mods = 'LEADER|SHIFT',
		action = act.SplitPane({ direction = 'Right' }),
	},
	{
		key = 'h',
		mods = 'LEADER',
		action = act.ActivatePaneDirection('Left'),
	},
	{
		key = 'j',
		mods = 'LEADER',
		action = act.ActivatePaneDirection('Down'),
	},
	{
		key = 'k',
		mods = 'LEADER',
		action = act.ActivatePaneDirection('Up'),
	},
	{
		key = 'l',
		mods = 'LEADER',
		action = act.ActivatePaneDirection('Right'),
	},
	{
		key = 'w',
		mods = 'LEADER',
		action = act.CloseCurrentPane({ confirm = false }),
	},
	{
		key = 'v',
		mods = 'LEADER',
		action = act.ActivateCopyMode,
	},
	{
		key = 'f',
		mods = 'LEADER',
		action = act.Search({ CaseInSensitiveString = '' }),
	},
	{
		key = 'x',
		mods = 'LEADER',
		action = act.CloseCurrentTab({ confirm = true }),
	},
	-- Tab Management
	{
		key = 't',
		mods = 'LEADER',
		action = act.SpawnTab('CurrentPaneDomain'),
	},
	{
		key = 'n',
		mods = 'LEADER',
		action = act.ActivateTabRelative(1),
	},
	{
		key = 'p',
		mods = 'LEADER',
		action = act.ActivateTabRelative(-1),
	},
	{
		key = 'r',
		mods = 'LEADER',
		action = act.ActivateKeyTable({
			name = 'resize_pane',
			one_shot = false,
		}),
	},
	{
		key = 'F4',
		mods = '',
		action = act.TogglePaneZoomState,
	},
	{
		key = "'",
		mods = 'LEADER',
		action = act.ShowDebugOverlay,
	},
	{
		key = 'o',
		mods = 'ALT',
		action = wezterm.action.QuickSelectArgs({
			label = 'open',
			patterns = {
				[[\bhttps?://\S+\b]],
			},
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info('opening: ' .. url)
				wezterm.open_with(url)
			end),
		}),
	},
	{
		key = 's',
		mods = 'LEADER',
		action = act.PaneSelect,
	},
	{
		key = 's',
		mods = 'LEADER|SHIFT',
		action = act.PaneSelect({ mode = 'SwapWithActive' }),
	},
	{
		key = 'a',
		mods = 'LEADER|CTRL',
		action = act.ShowTabNavigator,
	},
}

for i = 1, 9 do
	table.insert(M.keys, {
		key = tostring(i),
		mods = 'LEADER',
		action = act.ActivateTab(i - 1),
	})
end

M.key_tables = {
	resize_pane = (function(size)
		return {
			{ key = 'LeftArrow', action = act.AdjustPaneSize({ 'Left', size }) },
			{ key = 'h', action = act.AdjustPaneSize({ 'Left', size }) },

			{ key = 'RightArrow', action = act.AdjustPaneSize({ 'Right', size }) },
			{ key = 'l', action = act.AdjustPaneSize({ 'Right', size }) },

			{ key = 'UpArrow', action = act.AdjustPaneSize({ 'Up', size }) },
			{ key = 'k', action = act.AdjustPaneSize({ 'Up', size }) },

			{ key = 'DownArrow', action = act.AdjustPaneSize({ 'Down', size }) },
			{ key = 'j', action = act.AdjustPaneSize({ 'Down', size }) },

			-- Cancel the mode by pressing escape
			{ key = 'Escape', action = 'PopKeyTable' },
			{ key = 'c', mods = 'CTRL', action = 'PopKeyTable' },
			{ key = '[', mods = 'CTRL', action = 'PopKeyTable' },
		}
	end)(3),
}

M.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'NONE',
		action = act.CompleteSelection('Clipboard'),
	},
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'CTRL',
		action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor('Clipboard'),
	},
	-- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
	{
		event = { Down = { streak = 1, button = 'Left' } },
		mods = 'CTRL',
		action = act.Nop,
	},
	-- Scrolling up while holding CTRL increases the font size
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = 'CTRL',
		action = act.IncreaseFontSize,
	},

	-- Scrolling down while holding CTRL decreases the font size
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = 'CTRL',
		action = act.DecreaseFontSize,
	},
}

M.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 5000 }

return M
