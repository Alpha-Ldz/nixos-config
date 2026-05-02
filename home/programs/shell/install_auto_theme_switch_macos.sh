#!/bin/bash
# Install LaunchAgent to automatically sync Terminal.app theme with system appearance
# This creates a background service that monitors system theme changes

set -e

if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/sync_terminal_with_system_theme_macos.sh"

# Check if sync script exists
if [[ ! -f "$SYNC_SCRIPT" ]]; then
    echo "❌ Sync script not found: $SYNC_SCRIPT"
    exit 1
fi

# Make sure it's executable
chmod +x "$SYNC_SCRIPT"

# Create LaunchAgent plist
PLIST_FILE="$HOME/Library/LaunchAgents/com.bluloco.terminal.theme.plist"

echo "📝 Creating LaunchAgent at: $PLIST_FILE"

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.bluloco.terminal.theme</string>

    <key>ProgramArguments</key>
    <array>
        <string>$SYNC_SCRIPT</string>
    </array>

    <key>WatchPaths</key>
    <array>
        <string>$HOME/Library/Preferences/.GlobalPreferences.plist</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/terminal-theme-sync.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/terminal-theme-sync.error.log</string>
</dict>
</plist>
EOF

echo "✅ LaunchAgent created"

# Load the agent
echo "🚀 Loading LaunchAgent..."
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo ""
echo "✅ DONE! Auto theme switching is now enabled"
echo ""
echo "📋 The Terminal theme will automatically sync when you:"
echo "   - Change macOS appearance (System Settings > Appearance)"
echo "   - Switch between Light and Dark mode"
echo ""
echo "🔍 Check logs:"
echo "   tail -f /tmp/terminal-theme-sync.log"
echo ""
echo "🛑 To disable:"
echo "   launchctl unload $PLIST_FILE"
echo "   rm $PLIST_FILE"
