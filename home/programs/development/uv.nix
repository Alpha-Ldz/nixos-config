{ pkgs, ... }:
{
  # uv - Fast Python package manager
  home.packages = with pkgs; [
    uv
  ];
}
