#!/usr/bin/env bash

set -euo pipefail

echo "Hi! This wizard will help you setup your Rasberry Pi (5)."
echo "Written by me, for me, myself and i :)"
echo
echo "To start off, please enter the hostname set during imaging:"
echo "(This should be excluding any suffixes such as .local etc.)"
read -p "Hostname: " HOSTNAME

echo "Great! Now onto setting up SSH and GPG keys. If I'm not mistaken,"
echo "there should be an USB stick with those on it. Expected ls(1) output:"
echo
echo "ssh priv.asc pub.asc"
echo
echo "Please insert your USB stick now. Press any key to continue."
read
echo "The drive is going to be mounted at /mnt. Output from lsblk(1):"
echo
lsblk
echo
echo "Please enter the name of the drive (ie. /dev/sda1)."
read -p "Name: " USB

echo "==> Mounting drive @ /mnt"
sudo mount "$USB" /mnt

echo "==> Copying over SSH keys."
[ ! -d ~/.ssh ] && mkdir ~/.ssh
cp -r /mnt/ssh/. ~/.ssh
sudo chown -R $(whoami) ~/.ssh
sudo chmod 600 ~/.ssh/*

echo "==> Copying over GPG keys (will be imported later)."
cp /mnt/priv.asc ~/
cp /mnt/pub.asc ~/

echo "==> Unmounting drive."
sudo umount /mnt

echo "==> Removing preinstalled bloatware."
sudo apt remove geany thonny lxterminal

echo "==> Performing full system upgrade."
sudo apt update
sudo apt full-upgrade

echo "==> Downloading GPG keys for additional repositories."
sudo mkdir -p /etc/apt/keyrings

[ ! -f /etc/apt/keyrings/gierens.gpg ] && wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
[ ! -f /etc/apt/keyrings/charm.gpg ] && wget -qO- https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg

echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list

sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/charm.gpg /etc/apt/sources.list.d/charm.list

echo "==> Pulling additional repositories."
sudo apt update

echo "==> Installing base system."
sudo apt install neovim rsync git curl htop wget gh pup gum bat eza fd-find ripgrep yt-dlp pass pass-otp imv mpv playerctl mosh aerc gpg gpg-agent bash gnome-keyring gcr sl cmatrix dosfstools ntfs-3g imagemagick lolcat cowsay fortune-mod alacritty

echo "==> Linking binaries"
[ ! -e /usr/bin/bat ] && sudo ln -s /usr/bin/batcat /usr/bin/bat

echo "==> Setting up binaries in $HOME"
mkdir -p "$HOME/bin/$HOSTNAME"
[ ! -L "$HOME/bin/$HOSTNAME.local" ] && ln -s "$HOME/bin/$HOSTNAME" "$HOME/bin/$HOSTNAME.local"

echo "==> Installing Helix"
HELIX_VERSION=25.01.1
HELIX_ARCHIVE=helix-$HELIX_VERSION-aarch64-linux

wget https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/$HELIX_ARCHIVE.tar.xz
tar -xf $HELIX_ARCHIVE.tar.xz && rm $HELIX_ARCHIVE.tar.xz
cp $HELIX_ARCHIVE/hx "$HOME/bin/$HOSTNAME/hx"
mkdir -p ~/.local/share/helix/runtime
cp -r $HELIX_ARCHIVE/runtime/. ~/.local/share/helix/runtime
rm -r $HELIX_ARCHIVE

echo "==> Pulling dotfiles"
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/sweet -o IdentitiesOnly=yes"

cd ~
[ ! -d .git ] && git init
if ! git remote | grep -q "^origin$"; then
    git remote add origin gitwastaken@dupunkto.org:meta/dotfiles
fi

echo "==> Fetching dotfiles."
git fetch

echo "Fetched dotfiles. If this is the first install, please"
echo "force checkout (git checkout -f master) to install them."
echo "Otherwise, DON'T! (It will overwrite EVERY FUCKING THING.)"
echo
read -p "Force checkout? [y/N]: " confirm

case "$confirm" in
    [Yy])
        echo "==> Checking out latest master."
        git checkout -f master
        ;;
    *)
        echo "OK."
        ;;
esac

echo "==> Sourcing shell environment."
source ~/etc/env

# To export GPG keys:
# gpg -a --export > pub.asc
# gpg --pinentry-mode loopback -a --export-secret-keys > priv.asc

if prompt -n "Import GPG keys?"; then
  echo "==> Importing GPG keys (you will be prompted for a password)."
  gpg --import pub.asc
  gpg --allow-secret-key-import --pinentry-mode loopback --import priv.asc
fi

echo "==> Setting restrictive permissions for keyfiles."
sudo chown -R $(whoami) ~/etc/gpg
sudo chmod 700 -R ~/etc/gpg

echo "==> Setting ownertrust."
gpg --list-secret-keys --with-colons | awk -F '/^fpr:/ { print $10 }' | while read -r fpr; do
  echo "$fpr:6:"
done | gpg --import-ownertrust

echo "==> Pulling passwords and 2FA codes."
[ ! -d $HOME/.local/share/passwords ] && git clone du:meta/passwords $HOME/.local/share/passwords
[ ! -d $HOME/.local/share/2fa ] && git clone du:meta/2fa $HOME/.local/share/2fa

echo "==> Setting up mailboxes."
mkdir -p "$XDG_CONFIG_HOME/aerc"
rsync -avP nov:accounts.conf "$XDG_CONFIG_HOME/aerc/"

echo "==> Finalizing"
git remote set-url origin du:meta/dotfiles
source ~/.bashrc
