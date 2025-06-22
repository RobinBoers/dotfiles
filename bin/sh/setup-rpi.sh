#!/usr/bin/env bash

set -euo pipefail

cd ~

echo "Hi! This wizard will help you setup your Rasberry Pi (5)."
echo "Written by me, for me, myself and i :)"
echo
read -p "Is this the intial setup? [y/N] " confirm

case "$confirm" in
    [Yy])
        echo "Great! Let's start getting your SSH and GPG keys. If I'm not mistaken,"
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
        ;;
    *)
        echo "Well that skips a lot of steps :)"
        echo
        ;;
esac

echo "==> Performing full system upgrade."
sudo apt update
sudo apt full-upgrade

echo "==> Clearing /etc/motd and /etc/issue."
sudo truncate -s 0 /etc/motd
sudo truncate -s 0 /etc/issue

echo "==> Installing console fonts."
sudo apt install terminus

read -p "Installed Terminus font. Launch console-setup? [y/N] " confirm

case "$confirm" in
    [Yy])
        sudo dpkg-reconfigure console-setup
        ;;
    *)
        echo "OK. You can always rerun the script to do console-setup anyway."
        ;;
esac

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
sudo apt install neovim rsync git curl htop wget gh pup gum bat eza fd-find ripgrep yt-dlp pass pass-otp imv mpv playerctl mosh aerc gpg gpg-agent bash sl cmatrix dosfstools ntfs-3g imagemagick lolcat cowsay fortune-mod keychain

echo "==> Installing build tools."
sudo apt install build-essential make meson checkinstall

if [ ! -f /usr/bin/meson-install ]; then
    sudo wget -qO /usr/bin/meson-install https://raw.githubusercontent.com/keithbowes/meson-install/refs/heads/main/meson-install
    sudo chmod +x /usr/bin/meson-install
fi

echo "==> Setting up binaries in $HOME."
mkdir -p "$HOME/bin/$(hostname)"
[ ! -L "$HOME/bin/$(hostname).local" ] && ln -s "$HOME/bin/$(hostname)" "$HOME/bin/$(hostname).local"

if ! command -v hx >/dev/null 2>&1; then
    echo "==> Installing Helix."
    HELIX_VERSION=25.01.1
    HELIX_ARCHIVE=helix-$HELIX_VERSION-aarch64-linux

    cd /tmp
    wget https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/$HELIX_ARCHIVE.tar.xz
    tar -xf $HELIX_ARCHIVE.tar.xz && rm $HELIX_ARCHIVE.tar.xz
    cp $HELIX_ARCHIVE/hx "$HOME/bin/$(hostname)/hx"
    mkdir -p ~/.local/share/helix/runtime
    cp -r $HELIX_ARCHIVE/runtime/. ~/.local/share/helix/runtime
    rm -r $HELIX_ARCHIVE
fi

echo "==> Pulling dotfiles."
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
read -p "Force checkout? [y/N] " confirm

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

echo "==> Installing wayland desktop."
sudo apt install sway dbus xwayland seatd alacritty tofi wob kanshi mako-notifier swaybg grim slurp wl-clipboard clipman wlsunset swayidle pipewire pipewire-pulse pipewire-bin wireplumber xdg-desktop-portal xdg-desktop-portal-wlr adwaita-icon-theme

if ! has swaylock || prompt -n "Reinstall swaylock-effects?"; then
    echo "==> Installing dependencies for swaylock-effects."
    sudo apt install libwayland-dev wayland-protocols scdoc libxkbcommon-dev libcairo2-dev libgdk-pixbuf-2.0-dev

    echo "==> Downloading swaylock-effects."
    [ -d /tmp/swaylock-effects ] && sudo rm -rf /tmp/swaylock-effects
    git clone https://github.com/mortie/swaylock-effects /tmp/swaylock-effects
    cd /tmp/swaylock-effects

    echo "==> Building swaylock-effects."
    meson build
    ninja -C build
    cd build
    echo "Swaylock, with fancy effects" > description-pak
    # The following pkgversion number is a dummy :)
    sudo checkinstall -y --pkgname swaylock-effects --pkgversion 2000 --provides swaylock meson-install
    sudo chmod +x /usr/local/bin/swaylock
    sudo chmod a+s /usr/local/bin/swaylock
fi

if ! has autotiling || prompt -n "Reinstall autotiling?"; then
    echo "==> Installing dependencies for autotiling."
    sudo apt install python3-i3ipc

    echo "==> Downloading autotiling."
    sudo wget -qO /usr/bin/autotiling https://raw.githubusercontent.com/nwg-piotr/autotiling/refs/heads/master/autotiling/main.py
    sudo chmod +x /usr/bin/autotiling
fi

echo "==> Installing browsers."
sudo apt install links2 chromium

echo "==> Installing fonts."
sudo apt install fonts-ibm-plex fonts-linuxlibertine

echo "==> Linking binaries."
[ ! -e /usr/bin/bat ] && sudo ln -s /usr/bin/batcat /usr/bin/bat
[ ! -e /usr/bin/imv ] && sudo ln -s /usr/bin/imv-wayland /usr/bin/imv
[ ! -e /usr/bin/links ] && sudo ln -s /usr/bin/links2 /usr/bin/links

echo "==> Finalizing"
cd ~
git remote set-url origin du:meta/dotfiles
source ~/.bashrc
