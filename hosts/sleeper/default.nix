# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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

  networking.hostName = "sleeper"; # Define your hostname.

  # TODO Move networking config here 

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  system.stateVersion = "24.05"; # Did you read the comment?
  hardware.nvidia.package = let 
  rcu_patch = pkgs.fetchpatch {
    url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
    hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
  };

  in config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "550.40.07";
    sha256_64bit = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
    sha256_aarch64 = "sha256-AV7KgRXYaQGBFl7zuRcfnTGr8rS5n13nGUIe3mJTXb4=";
    openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
    settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
    persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";

    patches = [ rcu_patch ];
  };


  environment.systemPackages = [
    pkgs.unstable.ollama
    pkgs.steam
  ];

  services.sunshine = {
    enable = true;
    #package = pkgs.sunshine.override {
    #  cudaSupport = true;
    #};
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;


}
