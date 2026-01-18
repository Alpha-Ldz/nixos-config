{ ... }:
{
  # Sunshine game streaming service
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Avahi for service discovery
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
  };
}
