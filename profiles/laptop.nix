{ pkgs, lib, ... }:
{
  imports = [ ./workstation.nix ];

  # Power management
  services.upower.enable = true;
  services.thermald.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  # Laptop-specific services
  services.logind = {
    settings = {
      Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "lock";
      };
    };
  };

  # Touchpad
  services.libinput.enable = true;

  # Laptop packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
  ];
}
