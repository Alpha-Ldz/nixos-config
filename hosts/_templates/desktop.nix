# Template for a standard desktop workstation
{ versions, ... }:
{
  imports = [
    # Profiles - what kind of machine is this
    ../../profiles/base.nix
    ../../profiles/workstation.nix
    ../../profiles/development.nix  # Remove if not needed

    # Features - choose what you need
    ../../features/desktop/hyprland.nix
    # ../../features/desktop/gnome.nix
    # ../../features/desktop/plasma.nix

    # Hardware - choose your GPU
    ../../features/hardware/nvidia.nix
    # ../../features/hardware/amd.nix

    # Services
    ../../features/services/docker.nix

    # Hardware and users
    ./hardware-configuration.nix
    ./users.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # CHANGE THESE
  networking.hostName = "CHANGEME";
  time.timeZone = "Europe/Paris";

  system.stateVersion = versions.nixos;
}
