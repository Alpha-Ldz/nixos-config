{ pkgs, config, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.${config.home.username} = {};
  };
}
