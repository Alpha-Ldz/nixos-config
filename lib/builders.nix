{ inputs, versions }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable nixpkgs-darwin home-manager home-manager-darwin darwin;
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
    # Create specialArgs for this host with platform info
    specialArgs = {
      inherit inputs versions;
      isDarwin = false;
      isLinux = true;
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
        home-manager.extraSpecialArgs = specialArgs;

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

  # Build a macOS host with nix-darwin and home-manager integration
  mkDarwinHost = {
    hostname,
    system ? "aarch64-darwin",
    users ? [],
    extraModules ? []
  }:
  let
    # Create specialArgs for this host with platform info
    specialArgs = {
      inherit inputs versions;
      isDarwin = true;
      isLinux = false;
    };
  in
  darwin.lib.darwinSystem {
    inherit system;
    inherit specialArgs;

    modules = [
      # Enable unfree packages for Darwin
      { nixpkgs.config.allowUnfree = true; }

      # Host configuration
      ../hosts/${hostname}

      # Home-manager integration (using Darwin-compatible version)
      home-manager-darwin.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = specialArgs;

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
