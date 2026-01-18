{ versions, ... }:
{
  # Base home-manager configuration
  # Note: home.username and home.homeDirectory should be set by the calling module
  # or will be auto-detected by home-manager in NixOS

  home.stateVersion = versions.homeManager;
  programs.home-manager.enable = true;
}
