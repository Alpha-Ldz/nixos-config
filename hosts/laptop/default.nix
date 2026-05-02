{ versions, ... }:
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/laptop.nix
    ../../profiles/development.nix

    ../../features/desktop/hyprland.nix
    ../../features/services/docker.nix
    ../../features/services/ssh.nix
    ../../features/services/tailscale.nix

    ./hardware-configuration.nix
    ./users.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "laptop";
  time.timeZone = "Europe/Paris";

  system.stateVersion = versions.nixos;
}
