{
  inputs,
  pkgs,
  ...
} : {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    zplug = {
      enable = true;
      plugins = [
        { name = "MichaelAquilina/zsh-you-should-use"; }
      ];
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    shellAliases = {
      c = "clear";
      ll = "ls -l";
      configuration = "sudo -E -s nvim /etc/nixos/configuration.nix";
      update = "sudo nixos-rebuild switch";
    };

    history = {
      size = 10000;
    };
  };
}
