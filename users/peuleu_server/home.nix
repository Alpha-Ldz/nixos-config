# nix/home-manager/home.nix

{ config, pkgs, ... }:

let
  # myuser = builtins.getEnv "USER";
  # myhome = builtins.getEnv "HOME";
  myuser = "peuleu_server";
  myhome = "/home/${myuser}";
in {
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.username = "${myuser}";
  home.homeDirectory = "${myhome}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
     neovim
     k3s
     cifs-utils
     nfs-utils
     git
  ];
  services.openssh.enable = true;
  programs = {
    home-manager.enable = true;
  };
}