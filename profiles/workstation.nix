{ pkgs, ... }:
{
  imports = [ ./base.nix ];

  # Fonts
  fonts.packages = with pkgs; [
    material-design-icons
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.fira-code
  ];

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Restore ALSA state on boot
  systemd.services.alsa-store = {
    description = "Store ALSA state";
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.alsa-utils}/bin/alsactl restore";
      RemainAfterExit = true;
    };
  };

  # Graphics
  hardware.graphics.enable = true;

  # Desktop packages
  environment.systemPackages = with pkgs; [
    kitty
    rofi
    pavucontrol
    alsa-utils
    xfce.thunar
  ];
}
