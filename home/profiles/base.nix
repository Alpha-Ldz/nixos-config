{ versions, isDarwin ? false, ... }:
{
  # Base home-manager configuration
  # Note: home.username and home.homeDirectory should be set by the calling module
  # or will be auto-detected by home-manager in NixOS

  # Use appropriate state version based on platform
  home.stateVersion = if isDarwin then "25.05" else versions.homeManager;
  programs.home-manager.enable = true;
}
