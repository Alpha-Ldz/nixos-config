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
    ./development/uv.nix
    ./development/github.nix
    ./development/cuda.nix
  ];
}
