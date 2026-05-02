{ config, lib, pkgs, ... }:
{
  # NVIDIA configuration
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;  # Enable open source driver for RTX 5090
    nvidiaSettings = true;
    # Use stable open driver for RTX 5090
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Enable persistence daemon for NVML/compute access (needed for Ollama GPU detection)
    nvidiaPersistenced = true;
  };

  # Enable nvidia-container-toolkit for Docker/Containerd
  hardware.nvidia-container-toolkit.enable = true;

  # NVIDIA environment variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    XCURSOR_SIZE = "24";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # nvidia-persistenced already handles GPU initialization
}
