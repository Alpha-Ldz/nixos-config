{ lib, ... }:
{
  # macOS-specific home configuration (for future use)

  # Disable Linux-specific features on macOS
  wayland.windowManager.hyprland.enable = lib.mkForce false;

  # macOS home directory is typically /Users/${username}
  # Set in user config when using standalone home-manager
}
