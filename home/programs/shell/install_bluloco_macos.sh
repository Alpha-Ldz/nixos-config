#!/bin/bash
# Install Bluloco themes directly into Terminal.app preferences on macOS
# This script must be run ON YOUR MAC

set -e

echo "🎨 Installing Bluloco themes for macOS Terminal.app..."

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Terminal.app preferences file
TERM_PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"

if [[ ! -f "$TERM_PLIST" ]]; then
    echo "❌ Terminal.app preferences not found at $TERM_PLIST"
    exit 1
fi

echo "✓ Found Terminal.app preferences"

# Function to set color in Terminal.app preferences
set_terminal_color() {
    local profile="$1"
    local key="$2"
    local r="$3"
    local g="$4"
    local b="$5"

    # Create NSColor data using Python (available on all macOS)
    /usr/bin/python3 << EOF
import plistlib
import sys

# Create NSColor archived data
color_string = f"$r $g $b 1.0"
archived = {
    '\$version': 100000,
    '\$archiver': 'NSKeyedArchiver',
    '\$top': {'root': plistlib.UID(1)},
    '\$objects': [
        '\$null',
        {
            '\$class': plistlib.UID(2),
            'NSColorSpace': 1,
            'NSComponents': color_string.encode('utf-8')
        },
        {
            '\$classname': 'NSColor',
            '\$classes': ['NSColor', 'NSObject']
        }
    ]
}

# Write to temporary file
color_data = plistlib.dumps(archived, fmt=plistlib.FMT_BINARY)
with open('/tmp/color_data.bin', 'wb') as f:
    f.write(color_data)
EOF

    # Import the color data into Terminal preferences
    /usr/bin/defaults write com.apple.Terminal "Window Settings" -dict-add "$profile" -dict "$key" -data "$(xxd -p /tmp/color_data.bin | tr -d '\n')"
}

# Function to create a complete profile
create_profile() {
    local name="$1"
    local bg_r="$2"
    local bg_g="$3"
    local bg_b="$4"
    local fg_r="$5"
    local fg_g="$6"
    local fg_b="$7"

    echo "Creating profile: $name"

    # Start with an empty profile
    /usr/bin/defaults write com.apple.Terminal "Window Settings" -dict-add "$name" -dict \
        "name" "$name" \
        "type" "Window Settings" \
        "ProfileCurrentVersion" -float 2.07 \
        "FontAntialias" -bool true \
        "FontWidthSpacing" -float 1.0 \
        "columnCount" -int 120 \
        "rowCount" -int 40 \
        "shellExitAction" -int 1 \
        "useOptionAsMetaKey" -bool true

    # Note: Colors need to be added with Python script above
    echo "  Setting colors via Python..."
}

echo ""
echo "📝 Creating Bluloco Dark profile..."

# Bluloco Dark colors (from bluloco-dark.conf)
# background #282c34 = (40, 44, 52) = (0.1568627451, 0.17254901961, 0.20392156863)
# foreground #ccd5e5 = (204, 213, 229) = (0.8, 0.83529411765, 0.89803921569)

create_profile "Bluloco Dark" \
    "0.1568627450980392" "0.17254901960784313" "0.20392156862745098" \
    "0.8" "0.8352941176470589" "0.8980392156862745"

echo ""
echo "📝 Creating Bluloco Light profile..."

# Bluloco Light colors (from bluloco-light.conf)
# background #f9f9f9 = (249, 249, 249) = (0.97647058824, 0.97647058824, 0.97647058824)
# foreground #373a41 = (55, 58, 65) = (0.21568627451, 0.22745098039, 0.25490196078)

create_profile "Bluloco Light" \
    "0.9764705882352941" "0.9764705882352941" "0.9764705882352941" \
    "0.21568627450980393" "0.22745098039215686" "0.2549019607843137"

echo ""
echo "⚠️  NOTE: This script creates basic profiles, but setting colors via defaults is complex."
echo ""
echo "📌 RECOMMENDED METHOD:"
echo "   1. Copy the .terminal files to your Mac"
echo "   2. Double-click Bluloco-Dark.terminal"
echo "   3. Double-click Bluloco-Light.terminal"
echo "   4. They will open in Terminal.app and be imported automatically"
echo ""
echo "🔍 If colors still appear black:"
echo "   1. Open Terminal.app"
echo "   2. Go to Preferences (Cmd+,)"
echo "   3. Select Profiles tab"
echo "   4. Select 'Bluloco Dark' in the left sidebar"
echo "   5. Look at the 'Text' tab - check if colors are visible"
echo "   6. If black, manually click on 'Text Color' and 'Background Color'"
echo "   7. Try using the eyedropper to pick colors from another app"
echo ""
echo "💡 Alternative: Use iTerm2 instead of Terminal.app"
echo "   iTerm2 has better theme support and can import .terminal files more reliably"
