{
  versions,
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Profiles - define what kind of machine this is
    ../../profiles/base.nix
    ../../profiles/gaming.nix
    ../../profiles/development.nix

    # Features - optional capabilities
    ../../features/desktop/hyprland.nix
    ../../features/hardware/nvidia.nix
    ../../features/services/docker.nix
    ../../features/services/ollama-server.nix  # Ollama natif avec GPU (même config en desktop et k3s-server)
    ../../features/services/ssh.nix

    # Hardware and users
    ./hardware-configuration.nix
    ./users.nix
    ./nix-ld.nix  # Enable dynamic linking for Playwright and other binaries
  ];

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    # Limiter le nombre de générations affichées
    configurationLimit = 15;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Use kernel 6.12 for RTX 5090 support (6.18 too new, no drivers)
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # NVIDIA kernel parameters for RTX 5090
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Kernel modules: NVIDIA (RTX 5090 with open source driver) + iSCSI (Longhorn)
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "iscsi_tcp" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.stable ];

  # Machine-specific settings
  networking.hostName = "sleeper";
  time.timeZone = "Europe/Paris";

  # nixpkgs configuration
  nixpkgs.config = {
    allowUnfree = true;
    # Accept NVIDIA Data Center driver license
    nvidia.acceptLicense = true;
    # Accept Android SDK license
    android_sdk.accept_license = true;
  };

  # Add nixpkgs-unstable overlay for Ollama (needed in both modes)
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    })
  ];

  system.stateVersion = versions.nixos;
}
