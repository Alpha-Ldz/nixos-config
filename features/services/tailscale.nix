{ ... }:
{
  # Enable Tailscale VPN service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Open Tailscale port in firewall
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  # Enable systemd-resolved for better DNS with Tailscale
  services.resolved.enable = true;
}
