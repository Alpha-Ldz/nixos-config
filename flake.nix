{
  description = "NixOS configuration with profile-oriented architecture";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-darwin = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
  let
    lib = import ./lib { inherit inputs; };
  in {
    inherit lib;

    nixosConfigurations = {
      laptop = lib.mkHost {
        hostname = "laptop";
        system = "x86_64-linux";
        users = [ "peuleu" ];
      };

      nixos-node-1 = lib.mkHost {
        hostname = "nixos-node-1";
        system = "x86_64-linux";
        users = [ "peuleu" ];
      };

      sleeper = lib.mkHost {
        hostname = "sleeper";
        system = "x86_64-linux";
        users = [ "peuleu" ];
      };
    };

    darwinConfigurations = {
      macbook = lib.mkDarwinHost {
        hostname = "macbook";
        system = "aarch64-darwin";
        users = [ "pierre-louis" ];
      };
    };

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
