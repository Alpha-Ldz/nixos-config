{ ... }:
{
  # Docker virtualization
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Users who need docker access should be added to docker group in their user config
}
