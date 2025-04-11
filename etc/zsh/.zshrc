# Save as much history as possible
export HISTSIZE=10000
export SAVEHIST=10000

# Don't put duplicate lines 
setopt histignorealldups

# Fix history on multiple terminals
setopt inc_append_history
setopt share_history

# Bare paths will cd
setopt autocd

# NO BEEPS!!
unsetopt beep

if [ "$TERM" = "linux" ]; then
  # NO ANNOYING BEEPS PLEASE!!
  setterm -blength 0
  clear
fi 

# Make delete key work
bindkey "^[[3~" delete-char

source ~/etc/env
source ~/etc/aliases
source ~/etc/profile

# Activate python venv (if it doesn't exist, run
# `python3 -m venv $XDG_DATA_HOME/venv` to create it)
# source $XDG_DATA_HOME/venv/bin/activate

# Prompt
GRAY="$(tput setaf 245)"
RED="$(tput setaf 1)"
RESET="$(tput sgr0)"

PS1="%{${GRAY}%}[%2~]%{${RED}%}%(?.. !!)%{${RESET}%} "

# Plugins

[ -d "$ASDF_DIR" ] && source "$ASDF_DIR/asdf.sh"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
[ -e "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Completions
fpath=(${ASDF_DIR}/completions $fpath)

if command -v brew &>/dev/null; then
  fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
fi

zstyle ':completion:*' menu select
zstyle :compinstall filename '/home/axcelott/etc/zsh/.zshrc'
#autoload -Uz compinit
#compinit

if command -v brew &>/dev/null; then
  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi
