{
  description = "NixOS configuration for Peuleu";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      laptop = let
        username = "peuleu";
	specialArgs = {inherit username inputs;};
      in
        nixpkgs.lib.nixosSystem {
	  inherit specialArgs;
	  system = "x86_64-linux";

          modules = [
            ./hosts/laptop
	    ./users/${username}/nixos.nix

	    home-manager.nixosModules.home-manager
	    {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = inputs // specialArgs;
              home-manager.users.${username} = import ./users/${username}/home.nix;
	    }
          ];
        };
    };
  };
}
