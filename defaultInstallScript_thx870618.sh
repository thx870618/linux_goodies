#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

echo "--- Starting System Configuration for Debian 13 (Trixie) ---"

# 1. Install Google Chrome
echo "Installing Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
apt update
apt install -y /tmp/google-chrome.deb

# 2. Install "Official" Firefox (Mozilla Binary via APT)
echo "Installing Firefox (Official APT)..."
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null


# Prioritize Mozilla repo over Debian's ESR
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

apt update && apt install -y firefox && apt remove -y firefox-esr

# 3. Install Plymouth Themes
echo "Installing Plymouth themes..."
apt install -y plymouth plymouth-themes

# 4. Set GRUB parameters to 'quiet splash'
echo "Configuring GRUB parameters..."
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
# Fallback if the line is non-standard
if ! grep -q "splash" /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&splash /' /etc/default/grub
fi

# 5. Set "trixie" theme and update GRUB
echo "Setting Plymouth theme to 'trixie'..."
# Ensure the theme exists before setting
if [ -d "/usr/share/plymouth/themes/trixie" ]; then
    plymouth-set-default-theme -R trixie
else
    echo "Warning: Trixie theme folder not found. Setting 'homeworld' as fallback."
    plymouth-set-default-theme -R homeworld
fi
update-grub

# 6. Ask for reboot
echo ""
echo "--- Configuration Complete ---"
read -p "A reboot is required to apply changes. Reboot now? (y/n): " choice
case "$choice" in 
  y|Y ) reboot;;
  n|N ) echo "Please remember to reboot later to see the new splash screen.";;
  * ) echo "Invalid input. Manual reboot required.";;
esac
