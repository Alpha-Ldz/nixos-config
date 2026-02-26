{ config, pkgs, lib, ... }:
{
  # k3s Agent Mode - Join an existing K3S cluster as a worker node
  #
  # IMPORTANT: You must configure the server URL and token before using this.
  # See /home/peuleu/nixos-config/K3S_JOIN_CLUSTER.md for instructions.

  # Configuration options for joining a cluster
  # You MUST set these values in your host-specific configuration or via environment
  options = {
    services.k3s-cluster = {
      serverUrl = lib.mkOption {
        type = lib.types.str;
        description = "URL of the K3S server to join (e.g., https://192.168.1.100:6443)";
        example = "https://192.168.1.100:6443";
      };

      tokenFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to file containing the K3S cluster token";
        default = /var/lib/rancher/k3s/token;
        example = "/var/lib/rancher/k3s/token";
      };
    };
  };

  config = {
    # k3s in agent mode
    services.k3s = {
      enable = true;
      role = "agent";

      # Server URL and token for joining the cluster
      serverAddr = config.services.k3s-cluster.serverUrl;
      tokenFile = config.services.k3s-cluster.tokenFile;

      extraFlags = toString [
        # Node labels (useful for pod scheduling)
        "--node-label=gpu=nvidia"
        "--node-label=gpu-type=dedicated"
        "--node-label=workload=llm"
      ];
    };

    # NVIDIA Container Toolkit with CDI (Container Device Interface) is enabled
    # at the system level (hardware.nvidia-container-toolkit.enable = true)
    # No additional containerd configuration needed - CDI is auto-detected

    # Open firewall for k3s agent
    networking.firewall = {
      allowedTCPPorts = [
        10250 # kubelet
      ];
      allowedUDPPorts = [
        8472  # flannel VXLAN
      ];
    };

    # Install kubectl and other kubernetes tools
    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      kubernetes-helm
      k9s  # Terminal UI for Kubernetes
    ];

    # Configure kubeconfig for root and users
    # In agent mode, kubeconfig needs to be copied from the server or use remote access
    environment.sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    # Ensure k3s has access to GPU
    systemd.services.k3s = {
      path = [ config.hardware.nvidia.package ];
      environment = {
        NVIDIA_VISIBLE_DEVICES = "all";
        NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
      };
    };

    # Warn user if token file doesn't exist
    system.activationScripts.checkK3sToken = lib.mkIf config.services.k3s.enable ''
      if [ ! -f "${config.services.k3s-cluster.tokenFile}" ]; then
        echo "⚠️  WARNING: K3S token file not found at ${config.services.k3s-cluster.tokenFile}"
        echo "   Please create this file with the cluster token before K3S will start successfully."
        echo "   See K3S_JOIN_CLUSTER.md for instructions."
      fi
    '';
  };
}
