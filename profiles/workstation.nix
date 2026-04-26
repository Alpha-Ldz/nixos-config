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
  services.pulseaudio.enable = false;
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
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver   # iHD pour Intel Gen 8+
      intel-vaapi-driver   # i965 fallback
      libvdpau-va-gl
    ];
  };

  # Desktop packages
  environment.systemPackages = with pkgs; [
    kitty
    rofi
    pavucontrol
  ];
}
