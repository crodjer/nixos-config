local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true
config.hide_mouse_cursor_when_typing = false

config.font_size = 10
config.font = wezterm.font_with_fallback {
  "Hack Nerd Font"
}

if wezterm.gui.get_appearance():find 'Dark' then
  config.color_scheme = 'Catppuccin Mocha'
else
  config.color_scheme = 'Catppuccin Latte'
end

return config
