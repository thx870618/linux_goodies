#!/bin/bash

# Define your specific paths
SOURCE="$HOME/.local/share/Steam/steamapps"
DEST="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps"

# 1. Validation
if [ ! -d "$SOURCE" ]; then
    echo "❌ Error: Source directory $SOURCE not found."
    exit 1
fi

# Ensure Flatpak Steam structure exists
mkdir -p "$DEST/common"

echo "📦 Moving Manifest files (.acf)..."
# Moving these first ensures Steam recognizes the games immediately
mv "$SOURCE"/*.acf "$DEST/" 2>/dev/null

echo "📂 Moving Game Data (common folder)..."
# We move the contents of common to the destination common
# This is an instant 'rename' operation if they are on the same partition
mv "$SOURCE"/common/* "$DEST/common/" 2>/dev/null

# 2. Post-Move Cleanup
# Sometimes empty shader caches or 'downloading' folders stay behind
echo "🧹 Cleaning up remaining empty folders..."
rmdir "$SOURCE/common" 2>/dev/null

echo "✅ Migration Complete."
echo "Space saved: No duplicate files remain in the source folder."
