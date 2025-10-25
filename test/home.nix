# nix/home-manager/home.nix

{ config, pkgs, ... }:

let
  # myuser = builtins.getEnv "USER";
  # myhome = builtins.getEnv "HOME";
  myuser = "peuleu_server";
  myhome = "/home/${myuser}";
in {
  home.username = "${myuser}";
  home.homeDirectory = "${myhome}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    neofetch
    neovim
    git
    curl
    wget
    font-awesome_5
    nerdfonts
  ];
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  programs = {
    home-manager.enable = true;
    fzf.enable = true;
    jq.enable = true;
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "catppuccin";
    };
    gnome-terminal = {
      enable = true;
      profile."b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        font = "Monospace 8";
        default = true;
        visibleName = "Terminal";
      };
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      history = {
        extended = true;
        ignoreSpace = true;
        share = false;
      };
      profileExtra = "if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi";
    };
  };
}