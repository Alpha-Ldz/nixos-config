{ pkgs, ... }:
let
  # Custom SDDM theme configuration matching Bluloco Dark
  sddmTheme = pkgs.stdenv.mkDerivation {
    name = "sddm-bluloco-theme";

    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
      sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/sugar-dark-bluloco
      cp -r * $out/share/sddm/themes/sugar-dark-bluloco/

      # Copy Bluloco wallpaper
      mkdir -p $out/share/sddm/themes/sugar-dark-bluloco/Backgrounds
      cp ${../../home/desktop/hyprland/wallpapers/bluloco-dark.png} $out/share/sddm/themes/sugar-dark-bluloco/Backgrounds/bluloco-dark.png

      # Customize theme.conf with Bluloco colors
      cat > $out/share/sddm/themes/sugar-dark-bluloco/theme.conf <<EOF
[General]
Background="Backgrounds/bluloco-dark.png"
DimBackgroundImage="0.0"
ScaleImageCropped="true"
ScreenWidth="3840"
ScreenHeight="1080"

# Bluloco Dark colors
AccentColor="#10b0fe"
BackgroundColor="#282c34"
OverrideLoginButtonTextColor="#ccd5e5"

# Blur
BlurRadius="50"

# Font
Font="Fira Code"
FontSize="12"
MainColor="#ccd5e5"
SecondaryColor="#61697a"

# Show components
FormPosition="center"
HeaderText="Welcome"
HourFormat="HH:mm"
DateFormat="dddd, MMMM d"

# Password field
PasswordFieldOutlined="true"
PasswordFieldCharacter="•"
PasswordLeftMargin="15"
PasswordTextColor="#ccd5e5"
PasswordFieldPlaceholderText="Password"

# Misc
TranslatePlaceholderText="true"
TranslateUsernamePlaceholderText="true"
Locale=""
ForceRightToLeft="false"
ForceLastUser="true"
ForcePasswordFocus="true"
ForceHideCompletePassword="false"
ForceHideVirtualKeyboardButton="false"
EOF
    '';
  };
in
{
  environment.systemPackages = [ sddmTheme ];

  services.displayManager.sddm = {
    theme = "sugar-dark-bluloco";
  };
}
