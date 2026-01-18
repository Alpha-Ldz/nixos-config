# Template for a laptop machine
{ versions, ... }:
{
  imports = [
    # Profiles
    ../../profiles/base.nix
    ../../profiles/laptop.nix  # Includes workstation + laptop-specific features
    ../../profiles/development.nix  # Remove if not needed

    # Features
    ../../features/desktop/hyprland.nix
    ../../features/hardware/nvidia.nix  # Or amd.nix, or remove for integrated graphics
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
