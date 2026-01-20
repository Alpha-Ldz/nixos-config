{ pkgs, inputs, lib, config, ... }:
{
  imports = [
    # Core home-manager config
    ../../home/profiles/base.nix

    # Programs (cross-platform)
    ../../home/programs

    # macOS-specific (pierre-louis is macOS-only)
    ../../home/platform/macos.nix
  ];

  # User-specific git config
  programs.git = {
    userName = "pierre-louis.landouzi";
    userEmail = "pierre-louis.landouzi@sopht.com";
  };
}
