{ pkgs, ... }:
{
  # Node.js development tools
  home.packages = with pkgs; [
    nodejs  # Includes npm
  ];
}
