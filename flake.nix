{
  description = "NixOS configuration with profile-oriented architecture";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
  let
    # Import lib with version constants and builders
    lib = import ./lib { inherit inputs; };
  in {
    # Expose lib for use in configs
    inherit lib;

    # NixOS configurations
    nixosConfigurations = {
      laptop = lib.mkHost {
        hostname = "laptop";
        system = "x86_64-linux";
        users = [ "peuleu" ];
      };

      sleeper = lib.mkHost {
        hostname = "sleeper";
        system = "x86_64-linux";
        users = [ "peuleu" ];
      };
    };

    # macOS configurations with nix-darwin
    darwinConfigurations = {
      macbook = lib.mkDarwinHost {
        hostname = "macbook";
        system = "aarch64-darwin";  # Use "x86_64-darwin" for Intel Macs
        users = [ "peuleu" ];
      };
    };

    # Standalone home-manager configurations (for non-NixOS/non-Darwin systems)
    homeConfigurations = {
      "peuleu@macos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./users/peuleu/home.nix
          ./home/platform/macos.nix
          {
            home.username = "peuleu";
            home.homeDirectory = "/Users/peuleu";
          }
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}
