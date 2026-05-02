{ pkgs, lib, config, ... }:
{
  imports = [ ./base.nix ];

  # Headless server configuration - no desktop environment
  # This ensures the GPU is not used by X/Wayland

  # Enable SSH for remote access
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";

  # Auto-login to a TTY session (optional, for easy local access)
  # Comment this out if you prefer manual login
  services.getty.autologinUser = "peuleu";

  # Essential server packages
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    btop
    nvtopPackages.full  # GPU monitoring

    # Network tools
    wget
    curl
    tmux
    screen

    # Development tools
    claude-code  # Claude AI assistant (uses same token as desktop session)

    # Container/k8s tools (more will be added by k3s service)
    docker
    docker-compose
  ];

  # Enable Docker for containerized workloads
  virtualisation.docker = {
    enable = true;
    # enableNvidia is handled via nvidia-container-toolkit in nvidia-headless.nix
    autoPrune.enable = true;
  };

  # Optimize kernel for server workloads
  boot.kernel.sysctl = {
    # Increase inotify watches for k8s
    "fs.inotify.max_user_instances" = 8192;
    "fs.inotify.max_user_watches" = 524288;

    # Network optimizations
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";

    # Enable IP forwarding for k8s
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  # Load kernel modules needed for k8s and Longhorn
  boot.kernelModules = [ "br_netfilter" "overlay" "iscsi_tcp" ];

  # Enable iSCSI support for Longhorn
  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
  };

  # Disable unnecessary services
  services.xserver.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;
}
