# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/desktop.nix
      ../../modules/hyprland.nix

      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "laptop";

  time.timeZone = "Europe/Paris";

  system.stateVersion = "25.11"; # Did you read the comment?
}
