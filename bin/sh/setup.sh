#!/bin/sh

echo "First copy over the 'github' SSH key to ~/.ssh/"
echo "Then edit the script to remove the following 'exit 1':"
exit 1

# Install stuff
doas apk add shadow tpl cpufreqd zzz neovim rsync lsblk links-graphics git curl htop wget github-cli pup gum eza bat fd ripgrep yt-dlp pass pass-otp chromium browserpass imv mpv playerctl mosh aerc openssh gpg gpg-agent bash gnome-keyring gcr sl cmatrix dosfstools ntfs-3g acpi imagemagick networkmanager networkmanager-wifi networkmanager-tui
doas apk add helix tree-sitter-elixir tree-sitter-markdown tree-sitter-javascript tree-sitter-html tree-sitter-css tree-sitter-rust tree-sitter-python tree-sitter-c tree-sitter-bash tree-sitter-json tree-sitter-typescript tree-sitter-toml tree-sitter-comment tree-sitter-ini

# TODO(robin): append the following to /etc/NetworkManager/NetworkManager.conf:
#[main]
#dhcp=internal
#plugins=ifupdown,keyfile
#auth-polkit=false
#[ifupdown]
#managed=true
#[device]
#wifi.scan-rand-mac-address=yes
#wifi.backend=wpa_supplicant

doas service networking stop
doas service wpa_supplicant stop
doas service networkmanager start

doas rc-update del networking boot
doas rc-update del wpa_supplicant boot

doas rc-update add tlp default
doas rc-update add cpufreqd default
doas service tlp start
doas service cpufreqd start

# Install WM
doas apk add sway dbus xwayland seatd alacritty tofi wob swaylock-effects kanshi mako autotiling swaybg grim slurp wl-clipboard clipman wlsunset swayidle eudev pipewire pipewire-pulse pipewire-tools wireplumber xdg-desktop-portal xdg-desktop-portal-wlr adwaita-icon-theme

doas setup-devd udev
doas sh -c "echo 'ACTION==\"add\", SUBSYSTEM==\"backlight\", RUN+=\"/bin/chgrp video /sys/class/backlight/%k/brightness\"' >> /etc/udev/rules.d/backlight.rules"
doas sh -c "echo 'ACTION==\"add\", SUBSYSTEM==\"backlight\", RUN+=\"/bin/chmod g+w /sys/class/backlight/%k/brightness\"' >> /etc/udev/rules.d/backlight.rules"

doas rc-update add dbus
doas service dbus start

doas rc-update add seatd
doas service seatd start
doas adduser $USER input
doas adduser $USER video
doas adduser $USER seat
doas adduser $USER audio
doas adduser $USER plugdev

doas apk install fonts-ibmplex-mono-nerd fonts-inter

# Instal zsh
doas apk add zsh
chsh $USER -s $(which zsh)

# Move networking to async level to speed up boot
doas mkdir /etc/runlevels/async
doas rc-update add -s default async

doas sh -c 'echo "::once:/sbin/openrc -q -q async" >> /etc/inittab'

doas rc-update del chronyd default
doas rc-update add chronyd async
doas rc-update add networkmanager async

# Pull in dotfiles
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/github -o IdentitiesOnly=yes"

cd ~
git init
git remote add origin git@dupunkto.org:meta/dotfiles
git fetch
git checkout -f master

# Fix permissions on GPG directory
chown -R $(whoami) ~/etc/gpg
chmod 600 ~/etc/gpg/*
chmod 700 ~/etc/gpg

# To import GPG keys:
#gpg --import public.key
#gpg --allow-secret-key-import --pinentry-mode loopback --import secret.key

source ~/etc/env

# Pull in passwords
git clone du:meta/passwords $HOME/.local/share/passwords

# Pull in aerc config
mkdir -p "$XDG_CONFIG_HOME/aerc"
rsync -avP axcelott@dupunkto.org:accounts.conf "$XDG_CONFIG_HOME/aerc/"

# Setup chroot for running *ew* glibc programs
# From https://wiki.alpinelinux.org/wiki/Running_glibc_programs
mkdeb

echo "Please run the following commands:"
echo
echo "apt update && apt upgrade"
echo "apt install npm"
echo "npm i -g bun"
echo "exit"
echo

chdeb

# Setup languages
doas apk add mise
doas apk add openssl-dev make automake autoconf ncurses-dev gcc g++ # Dependencies for compiling erlang
doas apk add rust cargo clang lld
doas apk add nodejs npm

echo
echo
echo "Please edit /etc/pam.d/login according to enable GNOME keyring on login: https://wiki.archlinux.org/title/GNOME/Keyring#PAM_step"
