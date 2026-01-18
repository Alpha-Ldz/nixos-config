{ pkgs, ... }:
{
  # Development tools profile (can be combined with any base profile)

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    claude-code
  ];
}
