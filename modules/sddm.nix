{inputs, pkgs, ...}: { 
  services = {
    displayManager = {
      sddm = {
        enable = true;
	wayland = {
	  enable = true;
	};
      };
    };
  };
}