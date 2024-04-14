#!/bin/sh

echo "First copy over the 'github' SSH key to ~/.ssh/"
echo "Then edit the script to remove the following 'exit 1':"
exit 1

# Install stuff
doas apk add shadow tpl neovim lsblk links git curl htop wget github-cli pup gum eza bat fd ripgrep yt-dlp pass chromium browserpass imv mpv playerctl mosh openssh bash gnome-keyring helix tree-sitter-javascript tree-sitter-html tree-sitter-css sl cmatrix dosfstools ntfs-3g acpi

# Enable TLP
doas rc-update add tlp
doas service tlp start

# Install WM
doas apk add sway dbus xwayland seatd alacritty tofi wob swaylock-effects kanshi mako autotiling swaybg grim slurp wl-clipboard clipman wlsunset gpg gpg-agent swayidle eudev pipewire pipewire-pulse pipewire-tools wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
doas setup-devd udev
# Set udev rules here

# Setup dbus
doas rc-update add dbus
doas service dbus start

# Setup seatd
doas rc-update add seatd
doas service seatd start
doas adduser $USER input
doas adduser $USER video
doas adduser $USER seat

# Instal zsh
doas apk add zsh

chsh $USER -s $(which zsh)

# Install fonts
doas apk install fonts-ibmplex-mono-nerd fonts-inter

# Move networking to async level to speed up boot
doas mkdir /etc/runlevels/async
doas rc-update add -s default async

doas sh -c 'echo "::once:/sbin/openrc async -q -q" >> /etc/inittab'

doas rc-update del networking boot
doas rc-update del wpa_supplicant boot
doas rc-update del chronyd default

doas rc-update add networking async
doas rc-update add wpa_supplicant async
doas rc-update add chronyd async

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

# Pull in passwords
git clone du:meta/passwords $HOME/.local/share/passwords

echo "Please edit /etc/pam.d/login according to enable GNOME keyring on login: https://wiki.archlinux.org/title/GNOME/Keyring#PAM_step"
