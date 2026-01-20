{ pkgs, inputs, lib, config, isLinux, isDarwin, ... }:
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
    userName = "Alpha-Ldz";
    userEmail = "pllandouzi@gmail.com";
  };
}
