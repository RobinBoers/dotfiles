#!/bin/sh

echo "First copy over the 'github' SSH key to ~/.ssh/"
echo "Then edit the script to remove the following 'exit 1':"
exit 1

# Make directories lowercase
sudo mv Downloads downloads
sudo mv Pictures pictures
sudo mv Documents documents
sudo mv Public public
sudo mv Applications applications
sudo mv Library library
sudo mv Movies movies
sudo mv Music music
sudo mv Desktop desktop

# Hide the useless ones
chflags hidden applications
chflags hidden library
chflags hidden public
chflags hidden desktop

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install packages
brew install coreutils neovim rsync git curl git-tools htop wget gh pup gum eza bat fd ripgrep yt-dlp pass pass-otp mosh aerc gpg gpg-agent bash sl cmatrix lolcat imagemagick php prettier rlwrap

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

source ~/etc/env

echo "Please import your GPG keys like this (and then remove exit 1):"
echo "gpg --import public.key"
echo "gpg --allow-secret-key-import --pinentry-mode loopback --import secret.key"

exit 1

# Pinentry-mac + touch ID
brew tap jorgelbg/tap
brew install pinentry-mac pinentry-touchid

pinentry-touchid -check || pinentry-touchid -fix
defaults write org.gpgtools.common UseKeychain -bool yes

echo "We're gonna setup pinentry now. This should show a prompt (twice) for your password. In it, enter your password and click 'Save in Keychain'"
prompt -y "Ready?"

echo "test" | gpg --clearsign --local-user CBDF033DB0E73C541469A284B624C660CDF0AB8A
echo "test" | gpg --clearsign --local-user F6C5FD1CA38FE80AEB7E5301B1181BC2D8530F64

defaults write org.gpgtools.common DisableKeychain -bool yes
gpgconf --kill gpg-agent # Restart GPG agent with pinentry-mac

# SSH keys
ssh -K $HOME/.ssh/github
ssh -K $HOME/.ssh/sweet

# Pull in passwords
git clone du:meta/passwords "$PASSWORD_STORE_DIR"

# Pull in aerc config
mkdir -p "$XDG_CONFIG_HOME/aerc"
rsync -avP axcelott@dupunkto.org:accounts.conf "$XDG_CONFIG_HOME/aerc/"

# Install mise
mkdir "$HOME/bin/$(hostname)"
curl https://mise.jdx.dev/mise-latest-macos-arm64 > "$HOME/bin/$(hostname)/mise"

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install applications
brew install --cask 1password-cli
brew install --cask chromedriver
brew install --cask google-cloud-sdk
brew install --cask iterm2

echo "Logging you in in gcloud CLI..."
gcloud auth application-default login

echo "From here on out, we'll be setting MacOS settings."

# Speed up animations
defaults write com.apple.dock "expose-animation-duration" -float 0.1
defaults write com.apple.dock "autohide-delay" -float 0

# Autohide dock, hide "recommendations" and only show open applications.
defaults write com.apple.dock "autohide" -bool true
defaults write com.apple.dock "show-recents" -bool false

# Open finder at home dir
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME"
# Show path bar at the bottom of Finder windows
defaults write com.apple.finder "ShowPathbar" -bool true
# Use columns view by default
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"
# Sort folders before files
defaults write com.apple.finder "_FXSortFoldersFirst" -bool true
# Show file extensions, and actually allow me to goddamn change them
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool true
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool false
# Search current folder
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"

# Make the fn keys work, instead of sending XF860 events
defaults write com.apple.HIToolbox "AppleFnUsageType" -int 0
defaults write NSGlobalDomain "com.apple.keyboard.fnState" -bool true

# Don't fuck with the spaces please
defaults write com.apple.dock "mru-spaces" -bool false
# Needed for TWM
defaults write com.apple.spaces "spans-displays" -bool true

# Write in plain text
defaults write com.apple.TextEdit "RichText" -bool false
defaults write com.apple.mail "PreferPlainText" -bool true
defaults write com.apple.TextEdit "SmartQuotes" -bool false
defaults write NSGlobalDomain "NSAutomaticCapitalizationEnabled" -bool false
defaults write NSGlobalDomain "NSAutomaticDashSubstitutionEnabled" -bool false
defaults write NSGlobalDomain "NSAutomaticPeriodSubstitutionEnabled" -bool false
defaults write NSGlobalDomain "NSAutomaticQuoteSubstitutionEnabled" -bool false
defaults write NSGlobalDomain "NSAutomaticSpellingCorrectionEnabled" -bool false

# Make task manager usable
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int 1

# Don't clutter all my file systems
defaults write com.apple.desktopservices "DSDontWriteNetworkStores" -bool true
defaults write com.apple.desktopservices "DSDontWriteUSBStores" -bool true

# Stop promoting iCloud please
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool false

# Expand panels by default
defaults write NSGlobalDomain "NSNavPanelExpandedStateForSaveMode" -boolean true
defaults write NSGlobalDomain "NSNavPanelExpandedStateForSaveMode2" -bool true
defaults write NSGlobalDomain "PMPrintingExpandedStateForPrint" -boolean true
defaults write NSGlobalDomain "PMPrintingExpandedStateForPrint2" -bool true

# Mail: copy addresses without name, show threads in chronological order and
# show inline attachments as regular ones.
defaults write com.apple.mail "AddressesIncludeNameOnPasteboard" -bool false
defaults write com.apple.mail "DraftsViewerAttributes" -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail "DraftsViewerAttributes" -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail "DraftsViewerAttributes" -dict-add "SortOrder" -string "received-date"
defaults write com.apple.mail "DisableInlineAttachmentViewing" -bool true
defaults write com.apple.mail "SpellCheckingBehavior" -string "NoSpellCheckingEnabled"

# Close the printing modal after finishing printing
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Locale
defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

# Make Chrome use the system-native print preview dialog, and
# expand it by default
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true
