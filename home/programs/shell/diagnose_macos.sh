#!/bin/bash
# Diagnostic script to run ON YOUR MAC to check Terminal.app theme import

echo "🔍 macOS Terminal.app Theme Diagnostic"
echo "======================================"
echo ""

# Check if Bluloco profiles exist
echo "1. Checking if Bluloco profiles are imported..."
if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "Bluloco Dark"; then
    echo "   ✅ Bluloco Dark found"
else
    echo "   ❌ Bluloco Dark NOT found"
    echo "      → Import the .terminal file first!"
fi

if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "Bluloco Light"; then
    echo "   ✅ Bluloco Light found"
else
    echo "   ❌ Bluloco Light NOT found"
fi

echo ""
echo "2. Checking current default profile..."
DEFAULT=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null)
echo "   Default: $DEFAULT"

echo ""
echo "3. Extracting Background Color from Bluloco Dark..."
# This is complex because it's binary data, but we can check if it exists
if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -A 20 "Bluloco Dark" | grep -q "BackgroundColor"; then
    echo "   ✅ BackgroundColor key exists"
else
    echo "   ❌ BackgroundColor key NOT found"
    echo "      → The import may have failed"
fi

echo ""
echo "4. Checking ProfileCurrentVersion..."
defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -A 5 "Bluloco Dark" | grep -i "version"

echo ""
echo "5. Checking Font..."
if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -A 20 "Bluloco Dark" | grep -q "Font"; then
    echo "   ✅ Font key exists"
else
    echo "   ❌ Font key NOT found"
fi

echo ""
echo "======================================"
echo "📝 MANUAL TEST"
echo "======================================"
echo ""
echo "Open Terminal.app and:"
echo "1. Go to Preferences (Cmd+,)"
echo "2. Click Profiles tab"
echo "3. Select 'Bluloco Dark' in left sidebar"
echo "4. Look at the preview window on the right"
echo "5. Check the 'Text' tab:"
echo "   - Text color should be: Light gray"
echo "   - Background color should be: Dark gray (NOT black)"
echo ""
echo "If Background shows BLACK:"
echo "   → Click on the background color swatch"
echo "   → Note the RGB values shown"
echo "   → It should be: R=40, G=44, B=52"
echo "   → If it shows R=0, G=0, B=0, the import failed"
echo ""
echo "======================================"
echo "🔧 QUICK FIX"
echo "======================================"
echo ""
echo "If background is still black, try this:"
echo ""
echo "1. In Terminal.app Preferences > Profiles"
echo "2. Select 'Bluloco Dark'"
echo "3. Go to 'Text' tab"
echo "4. Click on 'Background' color swatch"
echo "5. In the color picker, select 'RGB Sliders'"
echo "6. Set:"
echo "   Red:   40  (or 0.157 if 0-1 scale)"
echo "   Green: 44  (or 0.173)"
echo "   Blue:  52  (or 0.204)"
echo ""
echo "This manually sets the correct background color."
echo ""
