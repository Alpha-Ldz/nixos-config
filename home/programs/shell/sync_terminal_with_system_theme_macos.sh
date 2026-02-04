#!/bin/bash
# Sync Terminal.app theme with macOS system appearance (Dark/Light mode)
# This script detects the system theme and switches Terminal.app accordingly

set -e

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Detect macOS appearance mode
# Returns "Dark" or "Light" (or empty if not set)
APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

echo "🔍 Detected system appearance: $APPEARANCE"

if [[ "$APPEARANCE" == "Dark" ]]; then
    TARGET="Bluloco Dark"
else
    TARGET="Bluloco Light"
fi

# Get current default
CURRENT=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || echo "Basic")

if [[ "$CURRENT" == "$TARGET" ]]; then
    echo "✅ Terminal theme already matches system: $TARGET"
    exit 0
fi

echo "Switching Terminal theme: $CURRENT → $TARGET"

# Set the theme
defaults write com.apple.Terminal "Default Window Settings" -string "$TARGET"
defaults write com.apple.Terminal "Startup Window Settings" -string "$TARGET"

echo "✅ Terminal theme updated to: $TARGET"
echo ""
echo "📝 New Terminal windows will use: $TARGET"
