{ config, pkgs, lib, ... }:
{
  # k3s Lightweight Kubernetes
  services.k3s = {
    enable = true;
    role = "server";

    extraFlags = toString [
      # Disable unnecessary components for headless server
      "--disable=traefik"  # We can install our own ingress controller if needed

      # GPU support
      "--kubelet-arg=feature-gates=DevicePlugins=true"
    ];
  };

  # Open firewall for k3s
  networking.firewall = {
    allowedTCPPorts = [
      6443  # k3s API server
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

  # Install NVIDIA device plugin for Kubernetes (deployed as a daemonset)
  # This will be deployed via kubectl after k3s is running
  # Run: kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
}
