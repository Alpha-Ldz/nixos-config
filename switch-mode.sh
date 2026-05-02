#!/usr/bin/env bash

# Script pour basculer entre mode Desktop et mode Serveur K3S
# Usage: ./switch-mode.sh [desktop|server|boot-server|boot-desktop|status]
#
# REMARQUE: Avec NixOS specialisations, la méthode recommandée est de choisir
# au boot dans le menu systemd-boot. Ce script permet un switch sans redémarrage.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

note() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_current_mode() {
    # Check if we're running under a specialisation
    if [ -L /run/current-system/specialisation ]; then
        echo "server"
    else
        echo "desktop"
    fi
}

get_specialisation_path() {
    # Path to the k3s-server specialisation
    if [ -d /run/current-system/specialisation/k3s-server ]; then
        echo "/run/current-system/specialisation/k3s-server"
    else
        echo ""
    fi
}

switch_to_server() {
    info "Switching to K3S Server mode (without reboot)..."

    SPEC_PATH=$(get_specialisation_path)
    if [ -z "$SPEC_PATH" ]; then
        error "k3s-server specialisation not found. Did you run 'sudo nixos-rebuild switch'?"
    fi

    warn "\n⚠️  Important notes:"
    warn "  - This will switch to headless mode immediately"
    warn "  - Your graphical session will be terminated"
    warn "  - GPU will be dedicated to k3s/Ollama"
    warn "  - SSH will remain active"
    warn "  - You may need to switch to a TTY (Ctrl+Alt+F2)\n"

    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Activating server mode..."
        sudo "$SPEC_PATH/bin/switch-to-configuration" switch
        info "Server mode activated!"
    else
        info "Cancelled."
    fi
}

switch_to_desktop() {
    info "Switching to Desktop mode (without reboot)..."

    warn "\n⚠️  Important notes:"
    warn "  - This will restore GUI/Hyprland"
    warn "  - K3S and Ollama services will be stopped"
    warn "  - GPU will be available for desktop use\n"

    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Activating desktop mode..."
        sudo /run/current-system/bin/switch-to-configuration switch
        info "Desktop mode activated!"
        info "You may need to restart your display manager or reboot."
    else
        info "Cancelled."
    fi
}

boot_server() {
    info "Setting K3S Server as default boot option..."

    SPEC_PATH=$(get_specialisation_path)
    if [ -z "$SPEC_PATH" ]; then
        error "k3s-server specialisation not found. Did you run 'sudo nixos-rebuild switch'?"
    fi

    sudo "$SPEC_PATH/bin/switch-to-configuration" boot
    info "✓ K3S Server mode will be used on next boot."
    info "To activate now without reboot, run: ./switch-mode.sh server"
}

boot_desktop() {
    info "Setting Desktop as default boot option..."

    sudo /run/current-system/bin/switch-to-configuration boot
    info "✓ Desktop mode will be used on next boot."
    info "To activate now without reboot, run: ./switch-mode.sh desktop"
}

show_status() {
    local mode=$(check_current_mode)

    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}     Sleeper Configuration Status${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}\n"

    if [ "$mode" = "server" ]; then
        info "Current mode: K3S Server (headless)"
        echo ""
        echo "Services:"
        echo "  - K3S:    $(systemctl is-active k3s 2>/dev/null || echo 'inactive')"
        echo "  - Ollama: $(systemctl is-active ollama 2>/dev/null || echo 'inactive')"
        echo "  - Docker: $(systemctl is-active docker 2>/dev/null || echo 'inactive')"

        if command -v nvidia-smi &> /dev/null; then
            echo -e "\nGPU Status:"
            nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | \
                awk -F', ' '{printf "  GPU %s: %s\n    Utilization: %s%% | Memory: %sMB/%sMB\n", $1, $2, $3, $4, $5}' || \
                echo "  Unable to query GPU"
        fi

        if systemctl is-active k3s &> /dev/null; then
            echo -e "\nK3S Cluster:"
            sudo k3s kubectl get nodes 2>/dev/null | head -2 || echo "  Unable to query cluster"
        fi
    else
        info "Current mode: Desktop (Hyprland)"
        echo ""
        echo "Desktop Environment:"
        echo "  - Hyprland: $(systemctl --user is-active hyprland-session 2>/dev/null || echo 'check manually')"
        echo "  - Display:  $DISPLAY"
    fi

    echo ""
    note "Available modes:"
    echo "  • Desktop (default)  - GUI with Hyprland + GPU for gaming"
    echo "  • k3s-server        - Headless + GPU dedicated to k3s/Ollama"
    echo ""
    note "Switch modes at boot: Select 'NixOS (k3s-server)' in systemd-boot menu"
    echo ""
}

show_usage() {
    cat << EOF
${BLUE}Sleeper Mode Switcher${NC} - Toggle between Desktop and K3S Server modes

${GREEN}Usage:${NC} $0 [COMMAND]

${GREEN}Commands:${NC}
    ${YELLOW}status${NC}          Show current mode and service status

    ${YELLOW}server${NC}          Switch to K3S Server mode NOW (no reboot, terminates GUI)
    ${YELLOW}desktop${NC}         Switch to Desktop mode NOW (no reboot)

    ${YELLOW}boot-server${NC}     Set K3S Server as default for NEXT boot
    ${YELLOW}boot-desktop${NC}    Set Desktop as default for NEXT boot

    ${YELLOW}help${NC}            Show this help message

${GREEN}Recommended method:${NC}
  Choose mode at boot in the systemd-boot menu:
    - "NixOS" = Desktop mode
    - "NixOS (k3s-server)" = Server mode

${GREEN}Examples:${NC}
    $0 status              # Check current configuration
    $0 boot-server         # Make server mode default boot
    $0 server              # Activate server mode immediately (kills GUI!)

${GREEN}Quick tips:${NC}
  • Changes with 'server' or 'desktop' take effect immediately
  • Changes with 'boot-*' take effect on next reboot
  • Switching to server mode will terminate your graphical session
  • Use 'status' to see which mode is active

EOF
}

# Main
case "${1:-}" in
    server)
        current=$(check_current_mode)
        if [ "$current" = "server" ]; then
            warn "Already in server mode."
            exit 0
        fi
        switch_to_server
        ;;
    desktop)
        current=$(check_current_mode)
        if [ "$current" = "desktop" ]; then
            warn "Already in desktop mode."
            exit 0
        fi
        switch_to_desktop
        ;;
    boot-server)
        boot_server
        ;;
    boot-desktop)
        boot_desktop
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
