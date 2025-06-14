#!/usr/bin/env bash

set -euo pipefail

echo "First copy over the 'sweet' SSH key to ~/.ssh/"
echo "Then edit the script to remove the following 'exit 1':"
exit 1

sudo apt remove geany thonny lxterminal

sudo apt update
sudo apt full-upgrade

sudo mkdir -p /etc/apt/keyrings

wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
wget -qO- https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg

echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list

sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/charm.gpg /etc/apt/sources.list.d/charm.list

sudo apt update

sudo apt install neovim rsync git curl htop wget gh pup gum bat eza fd-find ripgrep yt-dlp pass pass-otp imv mpv playerctl mosh aerc gpg gpg-agent bash gnome-keyring gcr sl cmatrix dosfstools ntfs-3g imagemagick lolcat cowsay fortune-mod alacritty

# Pull in dotfiles
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/sweet -o IdentitiesOnly=yes"

cd ~
git init
if ! git remote | grep -q "^origin$"; then
    git remote add origin gitwastaken@dupunkto.org:meta/dotfiles
fi
git fetch
git checkout -f master

# Fix permissions on GPG directory
chown -R $(whoami) ~/etc/gpg
chmod 600 ~/etc/gpg/*
chmod 700 ~/etc/gpg

# To export GPG keys:
# gpg -a --export > pub.asc
# gpg --pinentry-mode loopback -a --export-secret-keys > priv.asc

# To import GPG keys:
#gpg --import pub.asc
#gpg --allow-secret-key-import --pinentry-mode loopback --import priv.asc

source ~/etc/env

git clone du:meta/passwords $HOME/.local/share/passwords
git clone du:meta/2fa $HOME/.local/share/2fa

mkdir -p "$XDG_CONFIG_HOME/aerc"
rsync -avP nov:accounts.conf "$XDG_CONFIG_HOME/aerc/"
