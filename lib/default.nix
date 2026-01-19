{ inputs }:
{
  # Version constants
  versions = {
    nixos = "25.11";
    homeManager = "25.11";
  };

  # Re-export builders
  mkHost = (import ./builders.nix { inherit inputs; }).mkHost;
}
