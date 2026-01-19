{
  pkgs,
  ...
} : {
  imports = [
    ./spotify.nix
    ./discord.nix
  ];
}
