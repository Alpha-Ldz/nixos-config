{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Use unstable nixpkgs for latest ollama version (0.18.0 vs 0.12.11 in stable)
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  # Ollama AI service - server mode (accessible from network)
  services.ollama = {
    enable = true;

    # Use latest ollama from unstable for newer model support
    package = pkgs-unstable.ollama;

    # Listen on all interfaces so K3s pods can access it
    host = "0.0.0.0";
    port = 11434;

    # GPU acceleration (CUDA for NVIDIA)
    acceleration = "cuda";
  };

  networking.firewall.allowedTCPPorts = [11434];
}
