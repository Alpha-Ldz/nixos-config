{
  versions,
  config,
  pkgs,
  lib,
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
    ../../features/services/ollama.nix
    ../../features/services/ssh.nix

    # K3S Agent - join cluster while in desktop mode for debugging
    ../../features/services/k3s-agent.nix
    ./k3s-cluster-config.nix

    # Hardware and users
    ./hardware-configuration.nix
    ./users.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Machine-specific settings
  networking.hostName = "sleeper";
  time.timeZone = "Europe/Paris";

  # Enable iSCSI support for Longhorn (needed for both desktop and k3s-server modes)
  boot.kernelModules = ["iscsi_tcp"];
  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:sleeper";
  };

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

    configuration = {
      imports = [
        # Base system
        ../../profiles/base.nix
        ../../profiles/k3s-server.nix

        # Server features
        ../../features/hardware/nvidia-headless.nix
        ../../features/services/k3s-agent.nix
        ../../features/services/ssh.nix
        # Note: No ollama-server.nix here - Ollama is managed by K3S

        # K3S cluster configuration (server URL and token)
        ./k3s-cluster-config.nix

        # Hardware and users (shared with desktop)
        ./hardware-configuration.nix
        ./users.nix
      ];

      # Bootloader (must be redefined when inheritParentConfig = false)
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Machine settings (must be redefined)
      networking.hostName = "sleeper";
      time.timeZone = "Europe/Paris";
      system.stateVersion = versions.nixos;
    };
  };
}
