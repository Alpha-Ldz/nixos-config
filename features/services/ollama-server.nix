{ config, pkgs, lib, ... }:
{
  # Ollama AI service with GPU support
  services.ollama = {
    enable = true;
    acceleration = "cuda";  # Use NVIDIA CUDA for GPU acceleration

    # Make Ollama accessible from other machines (useful for k3s pods)
    host = "0.0.0.0";
    port = 11434;

    # Use all available GPUs
    environmentVariables = {
      NVIDIA_VISIBLE_DEVICES = "all";
      NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
      OLLAMA_NUM_GPU = "999";  # Use all available GPUs
      OLLAMA_MAX_LOADED_MODELS = "4";  # Number of models to keep in memory
    };

    # Models will be stored in /var/lib/ollama
    # You can preload models here if needed
  };

  # Open firewall for Ollama
  networking.firewall.allowedTCPPorts = [ 11434 ];

  # Ensure Ollama service has GPU access
  systemd.services.ollama = {
    path = [ config.hardware.nvidia.package ];
    serviceConfig = {
      # Run with high priority for better GPU performance
      Nice = -10;
      # Ensure GPU is available before starting
      Requires = [ "nvidia-persistenced.service" ];
      After = [ "nvidia-persistenced.service" ];
    };
  };

  # Enable NVIDIA persistence daemon for better GPU performance
  hardware.nvidia.nvidiaPersistenced = true;

  # Install Ollama CLI
  environment.systemPackages = with pkgs; [
    unstable.ollama
  ];
}
