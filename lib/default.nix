{ inputs }:
let
  # Version constants
  versions = {
    nixos = "25.11";
    homeManager = "25.11";
  };

  # Import builders with versions
  builders = import ./builders.nix { inherit inputs versions; };
in
{
  # Export version constants
  inherit versions;

  # Re-export builders
  inherit (builders) mkHost mkDarwinHost;
}
