{ lib, config, pkgs, ... }:
{
  # macOS-specific home configuration

  # Disable Linux-specific features on macOS
  wayland.windowManager.hyprland.enable = lib.mkForce false;
  qt.enable = lib.mkForce false;  # Disable QT on macOS due to compatibility issues

  # macOS home directory is typically /Users/${username}
  # Set in user config when using standalone home-manager

  # Symlink Nix-installed apps to ~/Applications for Spotlight
  home.activation.aliasApplications = lib.hm.dag.entryAfter ["writeBoundary"] ''
    appsSrc="${config.home.homeDirectory}/Applications/Home Manager Apps"
    baseDir="${config.home.homeDirectory}/Applications"

    # Create directory if it doesn't exist
    mkdir -p "$appsSrc"

    # Remove old symlinks
    find "$appsSrc" -type l -delete

    # Create new symlinks for all .app bundles
    find "$newGenPath/home-files/Applications" -type l -name "*.app" 2>/dev/null | while read -r app; do
      $DRY_RUN_CMD ln -sf "$app" "$appsSrc/$(basename "$app")"
    done
  '';
}
