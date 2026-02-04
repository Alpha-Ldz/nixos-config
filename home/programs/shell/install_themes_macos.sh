#!/bin/bash
# Script to install Bluloco themes on macOS Terminal.app
# Run this script ON YOUR MAC

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Bluloco themes for macOS Terminal.app..."

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Check if plutil is available
if ! command -v plutil &> /dev/null; then
    echo "❌ plutil not found"
    exit 1
fi

# Validate the .terminal files
echo "Validating theme files..."

for theme in "Bluloco-Dark" "Bluloco-Light"; do
    theme_file="$SCRIPT_DIR/${theme}.terminal"

    if [[ ! -f "$theme_file" ]]; then
        echo "❌ File not found: $theme_file"
        exit 1
    fi

    # Validate plist format
    if ! plutil -lint "$theme_file" > /dev/null 2>&1; then
        echo "❌ Invalid plist format: $theme_file"
        echo "   Trying to fix..."

        # Try to convert to XML format
        plutil -convert xml1 "$theme_file"
    fi

    echo "✓ $theme validated"
done

# Install themes by opening them
echo ""
echo "Opening theme files in Terminal.app..."
echo "Terminal.app will prompt you to import each theme."
echo ""

open "$SCRIPT_DIR/Bluloco-Dark.terminal"
sleep 1
open "$SCRIPT_DIR/Bluloco-Light.terminal"

echo ""
echo "✓ Done! The themes should now appear in Terminal.app Preferences > Profiles"
echo ""
echo "If the themes still appear black:"
echo "1. Open Terminal.app Preferences"
echo "2. Go to Profiles tab"
echo "3. Select 'Bluloco Dark' or 'Bluloco Light'"
echo "4. Go to the 'Text' tab"
echo "5. Check if colors are properly set"
echo "6. If not, try deleting the profile and importing again"
