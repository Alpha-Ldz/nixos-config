{
  pkgs,
  ...
} : {
  imports = [
    ./kitty.nix
    ./starship.nix
    ./zsh.nix
    ./ssh-config.nix
  ];
}
