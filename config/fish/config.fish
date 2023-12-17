#!/usr/bin/env fish

function fish_prompt
  set -l prompt_symbol '$'
  fish_is_root_user; and set prompt_symbol '#'

  printf '%s%s@%s%s:%s%s%s%s ' (set_color green --bold) $USER \
	 $hostname (set_color normal) (set_color blue) (prompt_pwd) \
	 (set_color normal) $prompt_symbol
end

# Disables greeting when starting fish
function fish_greeting
end

source ~/config/env
source ~/config/aliases
source ~/config/profile

# Plugins

source $ASDF_DIR/asdf.fish
#starship init fish | source

