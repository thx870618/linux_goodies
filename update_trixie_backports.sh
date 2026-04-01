#!/bin/bash

# 1. Add Trixie Backports (DEB822 format)
echo "Adding trixie-backports repository..."
sudo tee /etc/apt/sources.list.d/debian-backports.sources <<EOF
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# 2. Enable 32-bit support (Crucial for MESA/Gaming)
sudo dpkg --add-architecture i386

# 3. Update package lists
sudo apt update

# 4. Install Kernel and Firmware from Backports
echo "Installing newer Kernel and Firmware..."
sudo apt install -t trixie-backports -y \
    linux-image-amd64 \
    linux-headers-amd64 \
    firmware-linux \
    firmware-linux-nonfree

# 5. Install MESA Drivers (64-bit and 32-bit)
echo "Installing updated MESA drivers..."
sudo apt install -t trixie-backports -y \
    libgl1-mesa-dri \
    libgl1-mesa-dri:i386 \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    mesa-va-drivers \
    mesa-vdpau-drivers

echo "----------------------------------------------------"
echo "Done! Please REBOOT to activate the new Kernel/MESA."
echo "----------------------------------------------------"
