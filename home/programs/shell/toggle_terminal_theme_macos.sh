#!/bin/bash
# Script to toggle between Bluloco Dark and Light on macOS Terminal.app
# Usage: ./toggle_terminal_theme_macos.sh [dark|light]

set -e

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Get current default profile
CURRENT=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || echo "Basic")

# Determine target theme
if [[ "$1" == "dark" ]]; then
    TARGET="Bluloco Dark"
elif [[ "$1" == "light" ]]; then
    TARGET="Bluloco Light"
else
    # Toggle based on current
    if [[ "$CURRENT" == "Bluloco Dark" ]]; then
        TARGET="Bluloco Light"
    else
        TARGET="Bluloco Dark"
    fi
fi

echo "Switching from '$CURRENT' to '$TARGET'..."

# Set as default
defaults write com.apple.Terminal "Default Window Settings" -string "$TARGET"
defaults write com.apple.Terminal "Startup Window Settings" -string "$TARGET"

echo "✅ Default theme set to: $TARGET"
echo ""
echo "📝 Note: Existing Terminal windows won't change."
echo "   - Open new windows/tabs to see the new theme"
echo "   - Or manually change profile: Shell > Change Profile"
echo ""
echo "💡 To change ALL open Terminal windows:"
echo "   Close all Terminal windows and reopen Terminal.app"
