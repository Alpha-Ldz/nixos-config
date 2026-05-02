{ pkgs, ... }:
{
  # Ollama AI service
  environment.systemPackages = [
    pkgs.unstable.ollama
  ];
}
