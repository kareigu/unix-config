local wezterm = require("wezterm")

local config = wezterm.config_builder()

local font_family = "BerkeleyMono Nerd Font"

if wezterm.hostname() == "WS" then
	config.default_prog = { "pwsh" }
end
config.color_scheme = "Kanagawa (Gogh)"
config.font = wezterm.font(font_family)
config.default_cursor_style = "BlinkingUnderline"
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
config.initial_rows = 30
config.initial_cols = 120
config.front_end = "OpenGL"
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.integrated_title_button_color = "#2d4f67"
config.freetype_load_target = "Light"
config.window_background_opacity = 0
config.win32_system_backdrop = "Mica"

local function set_max_fps_to_refresh(window)
	local max_refresh = wezterm.gui.screens().active.max_fps
	local overrides = window:get_config_overrides() or {}
	if max_refresh ~= nil then
		overrides.max_fps = max_refresh
		overrides.animation_fps = math.floor(overrides.max_fps / 2)
	end
	window:set_config_overrides(overrides)
end
wezterm.on("window-focus-changed", set_max_fps_to_refresh)

local leader_key = "a"
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
