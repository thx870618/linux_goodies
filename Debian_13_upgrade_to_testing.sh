#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

echo "--- Starting Debian Testing Upgrade ---"

# 1. Update current packages to latest Stable state
echo "Step 1: Updating current system..."
apt update && apt upgrade -y

# 2. Backup current sources.list
echo "Step 2: Backing up sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 3. Switch sources to 'testing'
# This replaces 'trixie' or 'stable' with 'testing'
echo "Step 3: Switching sources to testing..."
sed -i 's/trixie/testing/g' /etc/apt/sources.list
sed -i 's/stable/testing/g' /etc/apt/sources.list

# 4. Update package lists with new sources
echo "Step 4: Fetching testing package lists..."
apt update

# 5. Perform the upgrade
# 'full-upgrade' is required to handle changing dependencies
echo "Step 5: Performing full-upgrade..."
apt full-upgrade -y

# 6. Cleanup
echo "Step 6: Cleaning up old packages..."
apt autoremove -y
apt clean

echo "--- Upgrade Complete! Please reboot your system. ---"
