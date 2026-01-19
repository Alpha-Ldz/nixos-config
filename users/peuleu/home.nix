{ pkgs, inputs, lib, ... }:
{
  imports = [
    # Core home-manager config
    ../../home/profiles/base.nix

    # Programs (cross-platform)
    ../../home/programs

    # Linux-specific (always imported for NixOS)
    ../../home/desktop/hyprland
    ../../home/platform/linux.nix

    # For macOS: comment out hyprland and linux.nix, uncomment macos.nix
    # ../../home/platform/macos.nix
  ];

  # User-specific git config
  programs.git = {
    settings = {
      user = {
        name = "Alpha-Ldz";
        email = "pllandouzi@gmail.com";
      };
    };
  };
}
