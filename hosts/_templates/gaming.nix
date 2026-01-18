# Template for a gaming rig
{ versions, ... }:
{
  imports = [
    # Profiles
    ../../profiles/base.nix
    ../../profiles/gaming.nix  # Includes workstation + gaming features
    ../../profiles/development.nix  # Optional

    # Features
    ../../features/desktop/hyprland.nix
    ../../features/hardware/nvidia.nix  # Gaming usually needs dedicated GPU
    ../../features/services/docker.nix
    # ../../features/services/sunshine.nix  # For game streaming

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
