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
    config = {
      allowUnfree = true;
      cudaSupport = true;  # Required for CUDA-enabled ollama build
    };
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

    # Preload models at startup
    loadModels = [ "qwen3-coder:30b" ];

    # Performance tuning for RTX 5090 (32 GB VRAM)
    environmentVariables = {
      # Allow 4 concurrent requests (large VRAM budget)
      OLLAMA_NUM_PARALLEL = "4";

      # Keep up to 2 models loaded simultaneously
      OLLAMA_MAX_LOADED_MODELS = "2";

      # Unload models after 5min of inactivity (saves VRAM/power)
      OLLAMA_KEEP_ALIVE = "5m";

      # Optional: force CUDA device selection (usually auto-detected)
      # CUDA_VISIBLE_DEVICES = "0";
    };
  };

  # Fix GPU detection race condition: wait for nvidia-persistenced before starting Ollama
  # Also inject LD_LIBRARY_PATH for CUDA libs (NixOS module doesn't do this automatically)
  systemd.services.ollama = {
    after = [ "nvidia-persistenced.service" ];
    wants = [ "nvidia-persistenced.service" ];
    environment = {
      # Critical: tell Ollama where to find libcuda.so and other NVIDIA libs
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    };
  };

  networking.firewall.allowedTCPPorts = [ 11434 ];

  # Allow user to restart ollama without password (useful for debugging)
  security.sudo.extraRules = [{
    users = [ "peuleu" ];
    commands = [
      { command = "/run/current-system/sw/bin/systemctl start ollama"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl restart ollama"; options = [ "NOPASSWD" ]; }
    ];
  }];
}
