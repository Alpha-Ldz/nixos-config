{ pkgs, ... }:
{
  imports = [ ./base.nix ];

  # Fonts
  fonts.packages = with pkgs; [
    material-design-icons
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Audio
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Graphics
  hardware.graphics.enable = true;

  # Desktop packages
  environment.systemPackages = with pkgs; [
    kitty
    rofi
  ];
}
