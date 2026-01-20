{ inputs, pkgs, ... }:
{
  imports = [
    ./greetd.nix
  ];

  # Enable Hyprland window manager
  programs.hyprland.enable = true;

  # Wayland session environment
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
  };
}
