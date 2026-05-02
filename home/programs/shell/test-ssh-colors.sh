#!/usr/bin/env bash
# Test SSH color support
# Usage: ./test-ssh-colors.sh [user@]host

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 [user@]host"
    echo "Example: $0 peuleu@192.168.1.100"
    exit 1
fi

HOST="$1"

echo "🔍 Testing SSH color support for: $HOST"
echo "=========================================="
echo ""

echo "📡 1. Testing SSH connection..."
if ssh -o ConnectTimeout=5 "$HOST" "echo 'Connection OK'" > /dev/null 2>&1; then
    echo "   ✅ SSH connection successful"
else
    echo "   ❌ Cannot connect to $HOST"
    exit 1
fi

echo ""
echo "🎨 2. Checking TERM variable..."
REMOTE_TERM=$(ssh "$HOST" 'echo $TERM')
echo "   Local TERM:  $TERM"
echo "   Remote TERM: $REMOTE_TERM"

if [ "$REMOTE_TERM" = "xterm-256color" ] || [ "$REMOTE_TERM" = "screen-256color" ]; then
    echo "   ✅ TERM is correct"
else
    echo "   ⚠️  TERM may not support 256 colors"
fi

echo ""
echo "🌈 3. Checking COLORTERM variable..."
REMOTE_COLORTERM=$(ssh "$HOST" 'echo $COLORTERM')
echo "   Local COLORTERM:  $COLORTERM"
echo "   Remote COLORTERM: $REMOTE_COLORTERM"

if [ "$REMOTE_COLORTERM" = "truecolor" ]; then
    echo "   ✅ COLORTERM is correct"
else
    echo "   ⚠️  COLORTERM not set to truecolor"
fi

echo ""
echo "🔢 4. Checking color support..."
COLORS=$(ssh "$HOST" 'tput colors 2>/dev/null || echo "unknown"')
echo "   Available colors: $COLORS"

if [ "$COLORS" = "256" ]; then
    echo "   ✅ 256 color support detected"
elif [ "$COLORS" -ge 256 ]; then
    echo "   ✅ High color support detected ($COLORS colors)"
else
    echo "   ⚠️  Limited color support"
fi

echo ""
echo "🧪 5. Testing Neovim color support..."
NVIM_TEST=$(ssh "$HOST" "nvim --headless -c 'echo has(\"termguicolors\")' -c 'quit' 2>&1" | grep -o '[01]' | tail -1)

if [ "$NVIM_TEST" = "1" ]; then
    echo "   ✅ Neovim termguicolors is enabled"
else
    echo "   ⚠️  Neovim termguicolors may not be enabled"
fi

echo ""
echo "📊 Summary:"
echo "=========================================="

ISSUES=0

if [ "$REMOTE_TERM" != "xterm-256color" ] && [ "$REMOTE_TERM" != "screen-256color" ]; then
    echo "   ⚠️  TERM should be xterm-256color or screen-256color"
    ((ISSUES++))
fi

if [ "$REMOTE_COLORTERM" != "truecolor" ]; then
    echo "   ⚠️  COLORTERM should be truecolor"
    ((ISSUES++))
fi

if [ "$COLORS" != "256" ] && [ "$COLORS" -lt 256 ]; then
    echo "   ⚠️  Terminal should support 256 colors"
    ((ISSUES++))
fi

if [ "$NVIM_TEST" != "1" ]; then
    echo "   ⚠️  Neovim termguicolors should be enabled"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo "   ✅ All checks passed! Colors should work correctly."
    echo ""
    echo "💡 Try: ssh $HOST -t nvim"
else
    echo "   ⚠️  $ISSUES issue(s) found. See SSH_COLORS_TROUBLESHOOTING.md"
    echo ""
    echo "🔧 Quick fix:"
    echo "   1. sudo nixos-rebuild switch"
    echo "   2. Restart SSH session"
    echo "   3. Run this test again"
fi

echo ""
