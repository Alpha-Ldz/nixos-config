{ pkgs, ... }:
{
  # Docker tools
  home.packages = with pkgs; [
    docker          # Docker CLI
    docker-compose  # Docker Compose
  ];
}
