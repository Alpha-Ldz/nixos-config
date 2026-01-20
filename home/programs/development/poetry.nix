{ pkgs, ... }:
{
  # Python Poetry dependency management
  home.packages = with pkgs; [
    poetry
  ];
}
