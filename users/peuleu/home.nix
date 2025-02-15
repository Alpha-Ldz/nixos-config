{pkgs, inputs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/hyprland

    ../../home/programs
  ];
  programs = { 
	  git = {
			userName = "Alpha-Ldz";
			userEmail = "pllandouzi@gmail.com";
	  };
  };
}
