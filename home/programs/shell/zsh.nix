{
  inputs,
  pkgs,
  isDarwin ? false,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # On macOS, ensure nix-managed binaries take precedence over Homebrew
    initExtra =
      if isDarwin
      then ''
        export PATH="/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:$PATH"
      ''
      else ''
        # Set TERM for true color support
        export TERM=xterm-256color

        # Enable true color in terminal
        if [[ -n "$TMUX" ]]; then
          export TERM=screen-256color
        fi

        # Force true color support
        export COLORTERM=truecolor
      '';

    zplug = {
      enable = true;
      plugins = [
        {name = "MichaelAquilina/zsh-you-should-use";}
      ];
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
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
