local wezterm = require 'wezterm'
local config = wezterm.config_builder()

function is_dark()
  if wezterm.gui then
    return wezterm.gui.get_appearance():find("Dark")
  end
  return true
end

config.font = wezterm.font('BlexMono Nerd Font')
config.font_size = 21

config.scrollback_lines = 100000
  
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
  
config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"

-- fancy blur :D
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30

if is_dark() then
config.colors = {
  foreground = '#c9d1d9',
  background = '#0d1117',
  
  cursor_bg = '#c9d1d9',
  cursor_fg = '#0d1117',
  
  ansi = {
    '#0d1117', -- black
    '#ff7b72', -- red
    '#3fb950', -- green
    '#ffc300', -- yellow
    '#58a6ff', -- blue
    '#bc8cff', -- magenta
    '#39c5cf', -- cyan
    '#c9d1d9', -- white
  },
  brights = {
    '#484f58', -- bright black
    '#ff7b72', -- bright red
    '#3fb950', -- bright green
    '#ffc300', -- bright yellow
    '#58a6ff', -- bright blue
    '#bc8cff', -- bright magenta
    '#39c5cf', -- bright cyan
    '#ffffff', -- bright white
  },
}
else
  config.color_scheme = 'Github (base16)'
end

return config
