{
  pkgs,
  ...
} : {
  imports = [
    ./direnv.nix
    ./kitty.nix
    ./starship.nix
    ./zsh.nix
    ./ssh-config.nix
  ];
}
