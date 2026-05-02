{ pkgs, ... }:
{
  imports = [ ./workstation.nix ];

  # Performance CPU governor for gaming
  powerManagement.cpuFreqGovernor = "performance";

  # Gaming packages
  environment.systemPackages = with pkgs; [
    steam
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
