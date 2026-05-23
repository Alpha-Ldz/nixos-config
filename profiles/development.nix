{ pkgs, inputs, ... }:
{
  # Development tools profile (can be combined with any base profile)

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    claude-code
    android-tools
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.kicad-unstable
    freecad
    cura
  ];

  # Enable adb with proper udev rules
  programs.adb.enable = true;

  # Create adbusers group (programs.adb should do this but doesn't seem to)
  users.groups.adbusers = {};

  # Manual udev rule for ADB (needed for SSH sessions without local graphical session)
  services.udev.extraRules = ''
    # Huawei devices
    SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666", GROUP="adbusers"
  '';
}
