local wezterm = require("wezterm")

local config = wezterm.config_builder()

local font_family = "Mononoki Nerd Font Mono"

config.default_prog = { "pwsh" }
config.color_scheme = "Kanagawa (Gogh)"
config.font = wezterm.font(font_family)
config.window_frame = {
	font = wezterm.font({ family = font_family, weight = "Bold" }),
	active_titlebar_bg = "#1f1f28",
	inactive_titlebar_bg = "#1f1f28",
}

config.colors = {
	tab_bar = {
		inactive_tab_edge = "#1f1f28",
		background = "1f1f28",
		active_tab = {
			fg_color = "dcd7ba",
			bg_color = "1f1f28",
		},
		inactive_tab = {
			fg_color = "807d6c",
			bg_color = "14141a",
		},
	},
}

local leader_key = "b"
config.leader = { key = leader_key, mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "|",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = leader_key,
		mods = "LEADER",
		action = wezterm.action.SendKey({ key = leader_key, mods = "CTRL" }),
	},
}

return config
