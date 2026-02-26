{ config, lib, pkgs, ... }:
{
  # NVIDIA configuration for headless server (no X/Wayland)
  # GPU is dedicated to compute workloads (Ollama, k3s, etc.)

  # Load NVIDIA kernel modules
  boot.kernelModules = [ "nvidia" "nvidia_uvm" ];

  # Enable NVIDIA drivers
  # We need to set videoDrivers even in headless mode for nvidia-container-toolkit
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;

    # We don't need nvidia-settings on headless server
    nvidiaSettings = false;

    # Use stable drivers
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Enable persistence daemon for compute workloads
    nvidiaPersistenced = true;
  };

  # Essential NVIDIA environment variables for compute
  # No X/Wayland specific variables here
  environment.sessionVariables = {
    NVIDIA_VISIBLE_DEVICES = "all";
    NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
  };

  # Install NVIDIA container toolkit for k3s/docker
  virtualisation.containers.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  # System packages for GPU management
  environment.systemPackages = with pkgs; [
    nvtopPackages.full  # GPU monitoring
    cudaPackages.cudatoolkit  # CUDA toolkit
  ];

  # Ensure GPU is initialized at boot
  systemd.services.nvidia-smi-init = {
    description = "Initialize NVIDIA GPU";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.hardware.nvidia.package}/bin/nvidia-smi";
      RemainAfterExit = true;
    };
  };
}
