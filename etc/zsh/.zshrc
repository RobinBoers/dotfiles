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

# Prompt
prompt_st() { [ $? == 1 ] && echo ' !!'; }

GRAY="$(tput setaf 245)"
RED="$(tput setaf 1)"
RESET="$(tput sgr0)"

PS1="%{${GRAY}%}[%2~]%{${RED}%}%(?.. !!)%{${RESET}%} "

source ~/etc/env
source ~/etc/aliases
source ~/etc/profile

# Plugins

source "$ASDF_DIR/asdf.sh"

# Completions
fpath=(${ASDF_DIR}/completions $fpath)
zstyle ':completion:*' menu select
zstyle :compinstall filename '/home/axcelott/etc/zsh/.zshrc'
autoload -Uz compinit
compinit
