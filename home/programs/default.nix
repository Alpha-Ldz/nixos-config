{
  imports = [
    ./common.nix
    ./browsers/firefox.nix
    ./shell
    ./others
    ./editors/nixvim
    ./development/kubernetes.nix
    ./development/nodejs.nix
    ./development/poetry.nix
    ./development/docker.nix
  ];
}
