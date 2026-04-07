{pkgs, ...}: {
  imports = [
    ./spotify.nix
    ./discord.nix
    ./bitwarden.nix
    ./telegram.nix
    ./thunar.nix
 ];
}
