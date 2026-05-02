{pkgs, lib, isLinux ? true, ...}:
{
	home.packages = lib.optionals isLinux (with pkgs; [
		discord
	]);
}
