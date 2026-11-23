# Nested shells inherit PATH and FPATH and prepend to them again
typeset -U path fpath

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
fi 

# Make delete key work
bindkey "^[[3~" delete-char

# Performance optimization to prevent forks
has() { command -v "$1" >/dev/null 2>&1; }

source ~/etc/env
source ~/etc/aliases
source ~/etc/profile

# Activate python venv (if it doesn't exist, run
# `python3 -m venv $XDG_DATA_HOME/venv` to create it)
# source $XDG_DATA_HOME/venv/bin/activate

# Prompt
PS1="%F{245}${SSH_CLIENT:+(${SSH_HOST:-%m}) }[%2~]%F{red}%(?.. !!)%f "

# Plugins

if [ -d "$ASDF_DIR/completions" ]; then
  fpath=($ASDF_DIR/completions $fpath)
fi

zcompdump="$XDG_CACHE_HOME/zsh/zcompdump"

if [[ ! -d $zcompdump:h ]]; then
  command mkdir -p $zcompdump:h
fi

autoload -Uz compinit
compinit -d "$zcompdump"

[ -d "$ASDF_DIR" ] && source "$ASDF_DIR/asdf.sh"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
[ -e "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

. memo

memo ngrok completion
memo wt source zsh
memo wt completions zsh
memo sec completions zsh
memo passport completions zsh
memo rc completions zsh

# Completions
zstyle ':completion:*' menu select
zstyle :compinstall filename '/home/axcelott/etc/zsh/.zshrc'
