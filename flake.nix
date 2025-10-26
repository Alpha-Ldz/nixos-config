{
  description = "NixOS configuration for Peuleu";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    hyprland.url = "github:hyprwm/Hyprland";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    nixpkgs-unstable,
    ...
  }: let
     system = "aarch64-linux";
     myuser = "peuleu_server";
     pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations = {
        "${myuser}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./test/home.nix
          ];
        };
    };
  };
}