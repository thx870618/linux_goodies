#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root or with sudo"
  exit
fi

echo "--- Starting Automated Debian 13 Setup ---"

# 1. Install Flatpak and add Flathub
echo "Configuring Flatpak and Flathub..."
apt update && apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak update -y

# 2. Install Discord and Minion from Flathub
echo "Installing Discord and Minion..."
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub gg.minion.Minion

# 3. Install Google Chrome
echo "Installing Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
apt install -y /tmp/google-chrome.deb
rm /tmp/google-chrome.deb

# 4. Install Firefox via Official Mozilla APT Repo
echo "Setting up Mozilla APT repository..."
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Create the source list
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null

# Set priority to prefer Mozilla repo over Debian's Firefox-ESR
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla > /dev/null

apt update && apt install -y firefox

# 5. Remove Firefox-ESR
echo "Removing Firefox-ESR..."
apt purge -y firefox-esr

# 6. Enable 'quiet splash' in GRUB
echo "Configuring GRUB for quiet splash..."
# This uses sed to find the line and ensure both quiet and splash are present
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' /etc/default/grub
# Clean up potential duplicates if 'quiet' was already there
sed -i 's/quiet quiet/quiet/' /etc/default/grub
update-grub

# 9. Enable 32-bit Architecture and Install Steam
echo "Enabling 32-bit architecture for Steam..."
dpkg --add-architecture i386
apt update

echo "Downloading and installing Steam..."
# Download the official launcher from Valve's servers
wget -q https://repo.steampowered.com/steam/archive/stable/steam_latest.deb -O /tmp/steam.deb

# Using 'apt install' on the local file handles all the 32-bit dependencies automatically
apt install -y /tmp/steam.deb

# Clean up
rm /tmp/steam.deb

# 7. Install Plymouth themes and enable default Debian theme
echo "Setting up Plymouth splash screen..."
apt install -y plymouth plymouth-themes
plymouth-set-default-theme -R debian-logo
update-initramfs -u

# 8. Ask for reboot
echo "--- Setup Complete ---"
read -p "A reboot is required to apply all changes. Reboot now? (y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    reboot
else
    echo "Please remember to reboot later to see the new boot splash and GRUB changes."
fi
