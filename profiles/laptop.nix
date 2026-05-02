{ pkgs, lib, ... }:
{
  imports = [ ./workstation.nix ];

  # Power management
  services.upower.enable = true;
  services.thermald.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  # Laptop-specific services
  services.logind.lidSwitch = "lock";
  services.logind.lidSwitchExternalPower = "lock";

  # Touchpad
  services.libinput.enable = true;

  # Laptop packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
  ];
}
