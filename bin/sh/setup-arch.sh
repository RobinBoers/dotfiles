#!/usr/bin/env bash

# This script should be working, but has never actually been ran before. TODO for the
# future: make it entirely idempotent, like the Raspberry Pi setup script.

set -euo pipefail

cd ~

echo "==> Installing base system."
sudo pacman -S base base-devel bluez bluez-utils bluetui networkmanager inetutils pipewire pipewire-alsa pipewire-jack pipewire-pulse man-db man-pages dialog tailscale

echo "==> Installing AUR helper."
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si

echo "==> Installing userspace."
paru -S zsh aerc helix neovim lazygit eza fd ripgrep bat rsync curl wget spotdl yt-dlp pup gum jq go-yq bc cmatrix cowsay lolcat fortune-mod sl

echo "==> Setting shell."
sudo chsh $(whoami) -s $(which zsh)

echo "==> Setting group permissions for keymaps."
echo 'uinput' | sudo tee /etc/modules-load.d/uinput.conf
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/99-input.rules
sudo gpasswd -a $(whoami) input

echo "==> Setting up binaries in $HOME."
mkdir -p "$HOME/bin/$(hostname)"
[ ! -L "$HOME/bin/$(hostname).local" ] && ln -s "$HOME/bin/$(hostname)" "$HOME/bin/$(hostname).local"

echo "==> Pulling dotfiles."
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/github -o IdentitiesOnly=yes"

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

echo "==> Creating directory structure."
mkdir -p ~/downloads
mkdir -p ~/pictures/wallpapers

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
if [ ! -d $HOME/.local/share/passwords ]; then
  git clone du:meta/passwords $HOME/.local/share/passwords
fi

echo "==> Setting up mailboxes."
mkdir -p "$XDG_CONFIG_HOME/aerc"

if [ ! -e "$XDG_CONFIG_HOME/aerc/accounts.conf" ]; then
  rsync -av nov:etc/aerc/ "$XDG_CONFIG_HOME/aerc/"
fi

echo "==> Installing wayland desktop."
paru -S sway swaybg swayidle swaylock-effects tofi autotiling grim slurp imv mpv alacritty kanshi mako wob playerctl wlsunset wl-clipboard clipman xdg-desktop-portal xdg-desktop-portal-wlr xorg-xwayland xremap-wlroots-bin

echo "==> Bootstrapping development environment."
paru -S git postgresql docker mosh github-cli flyctl-bin meson mise inotify-tools lftp

echo "==> Installing browsers."
paru -S chromium librewolf-bin
sudo ln -s /usr/bin/librewolf /usr/local/bin/firefox

echo "==> Installing password managers."
paru -S pass pass-otp browserpass browserpass-chromium browserpass-librewolf

echo "==> Installing fonts."
paru -S inter-font terminus-font ttf-libertinus ttf-victor-mono

echo "==> Downloading wallpapers."
git clone gh:RobinBoers/wallpapers ~/pictures/wallpapers

echo "==> Downloading fonts."
if [ ! -d $HOME/.local/share/fonts ]; then
    rsync -av nov:fonts/ ~/.local/share/fonts/
fi

fc-cache -f

echo "==> Downloading themes."
if [ ! -d $HOME/.local/share/themes ]; then
    rsync -av nov:themes/ ~/.local/share/themes/
fi

echo "==> Finalizing."
cd ~
git remote set-url origin du:meta/dotfiles
source ~/.bashrc
