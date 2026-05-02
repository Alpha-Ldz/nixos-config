{
  versions,
  config,
  pkgs,
  ...
}: {
  # This is an alternative configuration for 'sleeper' in K3S server mode
  # To use this configuration:
  # 1. Backup your current configuration
  # 2. Replace the content of hosts/sleeper/default.nix with this file
  # 3. Run: sudo nixos-rebuild switch
  # 4. The system will reboot into headless server mode with GPU dedicated to k3s

  imports = [
    # Profiles - headless k3s server
    ../../profiles/base.nix
    ../../profiles/k3s-server.nix

    # Features - GPU and services
    ../../features/hardware/nvidia-headless.nix
    ../../features/services/k3s.nix
    ../../features/services/ollama-server.nix
    ../../features/services/ssh.nix

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

  system.stateVersion = versions.nixos;
}
