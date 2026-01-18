{ inputs, pkgs, ... }:
{
  # Enable Hyprland window manager
  programs.hyprland.enable = true;

  # Display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Wayland session environment
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
  };
}
