#!/bin/bash

# Define paths
# SOURCE: Flatpak Steam path
# DEST: Native Steam path (as specified: ~/.local/share/Steam/steamapps)
SOURCE="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps"
DEST="$HOME/.local/share/Steam/steamapps"

# 1. Validation
if [ ! -d "$SOURCE" ]; then
    echo "❌ Error: Flatpak Steam folder not found at $SOURCE"
    exit 1
fi

# Ensure Native Steam structure exists
mkdir -p "$DEST/common"

echo "🔄 Migrating games back to Native Steam..."

# 2. Move the Manifest files (.acf)
# These are the "brain" of the library; moving them tells Steam the games are installed.
echo "📦 Moving app manifests (.acf files)..."
mv "$SOURCE"/*.acf "$DEST/" 2>/dev/null

# 3. Move the Game Data (common folder)
# This moves the actual game files.
echo "📂 Moving game folders from 'common'..."
if [ "$(ls -A "$SOURCE/common/")" ]; then
    mv "$SOURCE"/common/* "$DEST/common/"
else
    echo "⚠️  No game folders found in $SOURCE/common/"
fi

# 4. Cleanup
# Removes the now-empty 'common' folder in the Flatpak directory
echo "🧹 Cleaning up..."
rmdir "$SOURCE/common" 2>/dev/null

echo "✅ Migration Complete!"
echo "Native Steam is now populated. Please launch the native Steam client."
