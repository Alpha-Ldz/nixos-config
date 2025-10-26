{
  description = "NixOS configuration for Peuleu";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
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
  }: {
    homeConfigurations = {
      rpi5 = let
        system = "aarch64-linux";
        myuser = "peuleu_server";
        specialArgs = {inherit inputs;};
      in
        home-manager.lib.homeManagerConfiguration {
          inherit specialArgs;
          modules = [
            ./test/home.nix
          ];
        };
    };
  };
}