{ versions, ... }:
{
  imports = [
    # Profiles - define what kind of machine this is
    ../../profiles/base.nix
    ../../profiles/laptop.nix
    ../../profiles/development.nix

    # Features - optional capabilities
    ../../features/desktop/hyprland.nix
    ../../features/hardware/nvidia.nix
    ../../features/services/docker.nix

    # Hardware and users
    ./hardware-configuration.nix
    ./users.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Machine-specific settings
  networking.hostName = "laptop";
  time.timeZone = "Europe/Paris";

  system.stateVersion = versions.nixos;
}
