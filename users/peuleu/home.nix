{ pkgs, inputs, lib, config, ... }:
let
  # Detect platform without using pkgs (which causes infinite recursion)
  isLinux = builtins.match ".*linux.*" builtins.currentSystem != null;
  isDarwin = builtins.match ".*darwin.*" builtins.currentSystem != null;
in
{
  imports = [
    # Core home-manager config
    ../../home/profiles/base.nix

    # Programs (cross-platform)
    ../../home/programs
  ] ++ lib.optionals isLinux [
    # Linux-specific
    ../../home/desktop/hyprland
    ../../home/platform/linux.nix
  ] ++ lib.optionals isDarwin [
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
