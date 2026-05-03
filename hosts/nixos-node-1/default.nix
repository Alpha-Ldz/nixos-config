{ versions, ... }:
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/laptop.nix
    ../../profiles/development.nix

    ../../features/desktop/hyprland.nix
    ../../features/services/docker.nix
    ../../features/services/ssh.nix

    ./hardware-configuration.nix
    ./users.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-node-1";
  time.timeZone = "Europe/Paris";

  zramSwap.enable = true;
  services.preload.enable = true;

  system.stateVersion = versions.nixos;
}
