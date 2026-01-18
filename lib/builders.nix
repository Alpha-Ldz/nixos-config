{ inputs }:
let
  inherit (inputs) nixpkgs home-manager;
  # Import our custom versions
  versions = (import ./default.nix { inherit inputs; }).versions;
in
{
  # Build a NixOS host with home-manager integration
  mkHost = {
    hostname,
    system ? "x86_64-linux",
    users ? [],
    extraModules ? []
  }:
  let
    # Create specialArgs for this host
    specialArgs = {
      inherit inputs versions;
    };
  in
  nixpkgs.lib.nixosSystem {
    inherit system;
    inherit specialArgs;

    modules = [
      # Host configuration
      ../hosts/${hostname}

      # Home-manager integration
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = inputs // specialArgs;

        # Import home configs for each user
        home-manager.users = builtins.listToAttrs (
          map (username: {
            name = username;
            value = import ../users/${username}/home.nix;
          }) users
        );
      }
    ] ++ extraModules;
  };
}
