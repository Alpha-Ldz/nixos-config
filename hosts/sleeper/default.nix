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
    ../../features/services/thermal-monitor.nix
    ../../features/services/vnc.nix

    # Hardware and users
    ./hardware-configuration.nix
    ./users.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
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

  # Enable iSCSI support for Longhorn (needed for both desktop and k3s-server modes)
  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:sleeper";
  };

  # Thermal and power monitoring with notifications (desktop mode)
  services.thermal-monitor.enable = true;

  # Create symlinks for Longhorn to find iSCSI tools (NixOS-specific)
  system.activationScripts.longhornIscsiLinks = ''
    mkdir -p /usr/bin /sbin
    ln -sf /run/current-system/sw/bin/iscsiadm /usr/bin/iscsiadm
    ln -sf /run/current-system/sw/bin/iscsiadm /sbin/iscsiadm
  '';

  system.stateVersion = versions.nixos;

  # Specialisation: K3S Agent Mode
  # This creates a second boot entry for headless k3s agent that joins an existing cluster
  # GPU 100% dedicated to k3s, Ollama and other LLM workloads are managed by K3S
  specialisation.k3s-server = {
    inheritParentConfig = false;

    configuration = { config, pkgs, lib, inputs, versions, ... }: {
      imports = [
        # Base system
        ../../profiles/base.nix
        ../../profiles/k3s-server.nix

        # Server features
        ../../features/hardware/nvidia-headless.nix
        ../../features/services/k3s-agent.nix
        ../../features/services/ssh.nix
        ../../features/services/ollama-server.nix  # Ollama natif avec GPU
        ../../features/services/thermal-monitor.nix

        # K3S cluster configuration (server URL and token)
        ./k3s-cluster-config.nix

        # Hardware and users (shared with desktop)
        ./hardware-configuration.nix
        ./users.nix
      ];

      # nixpkgs configuration
      nixpkgs.config = {
        allowUnfree = true;
        # Accept NVIDIA Data Center driver license
        nvidia.acceptLicense = true;
      };

      # Add nixpkgs-unstable overlay for Ollama
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = prev.system;
            config.allowUnfree = true;
          };
        })
      ];

      # Bootloader (must be redefined when inheritParentConfig = false)
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Use kernel 6.12 for RTX 5090 support (6.18 too new, no drivers)
      boot.kernelPackages = pkgs.linuxPackages_6_12;

      # NVIDIA kernel parameters for RTX 5090
      boot.kernelParams = [ "nvidia-drm.modeset=1" ];

      # Kernel modules: NVIDIA (RTX 5090 with open source driver) + iSCSI (Longhorn)
      boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "iscsi_tcp" ];
      boot.extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.stable ];

      # Enable iSCSI support for Longhorn (must be redefined when inheritParentConfig = false)
      services.openiscsi = {
        enable = true;
        name = "iqn.2016-04.com.open-iscsi:sleeper";
      };

      # Create symlinks for Longhorn to find iSCSI tools
      system.activationScripts.longhornIscsiLinks = ''
        mkdir -p /usr/bin /sbin
        ln -sf /run/current-system/sw/bin/iscsiadm /usr/bin/iscsiadm
        ln -sf /run/current-system/sw/bin/iscsiadm /sbin/iscsiadm
      '';

      # Thermal and power monitoring (headless mode - logs only, no notifications)
      services.thermal-monitor.enable = true;

      # Machine settings (must be redefined)
      networking.hostName = "sleeper";
      time.timeZone = "Europe/Paris";
      system.stateVersion = versions.nixos;
    };
  };
}
