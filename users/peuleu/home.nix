{ pkgs, inputs, lib, ... }:
{
  imports = [
    # Core home-manager config
    ../../home/profiles/base.nix

    # Programs (cross-platform)
    ../../home/programs
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific
    ../../home/desktop/hyprland
    ../../home/platform/linux.nix
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific
    ../../home/platform/macos.nix
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
