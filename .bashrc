# Make bash follow XDG standards

_confdir=${XDG_CONFIG_HOME:-$HOME/etc}/bash
_sharedir=${XDG_DATA_HOME:-$HOME/.local/share}/bash

if [ -d "$_confdir" ]; then
	. "$_confdir"/bashrc
fi

if [ ! -d "$_sharedir" ]; then
	mkdir -p "$_sharedir"
fi

HISTFILE="$_sharedir"/bash_history

unset _confdir
unset _sharedir
