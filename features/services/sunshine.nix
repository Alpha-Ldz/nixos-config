{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.sunshine ];

  # udev rules for virtual input devices (keyboard/mouse emulation)
  services.udev.packages = [ pkgs.sunshine ];

  # Sunshine streaming ports
  networking.firewall = {
    allowedTCPPorts = [ 47984 47989 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
    ];
  };

  # sunshine needs /dev/uinput access
  users.groups.input = {};

  # Run sunshine as a user systemd service
  systemd.user.services.sunshine = {
    description = "Sunshine game streaming server";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Restart = "on-failure";
    };
  };
}
