{ pkgs, ... }:
{
  home.packages = [
    pkgs.unstable.claude-code
  ];

  programs = {
    zsh.enable = true;
    k9s.enable = true;
  };
}
