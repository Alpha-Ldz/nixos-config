{ pkgs, ... }:
{
  # Python development tools
  home.packages = with pkgs; [
    python313
    poetry
  ];
}
