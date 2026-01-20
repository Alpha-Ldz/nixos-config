{
  pkgs,
  ...
} : {
  imports = [
    ./spotify.nix
    ./discord.nix
    ./bitwarden.nix
  ];
}
