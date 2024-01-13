local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true

config.font_size = 10
config.font = wezterm.font_with_fallback {
  "Hack Nerd Font"
}
config.color_scheme = "Catppuccin Latte"

return config
