{
  pkgs,
  ...
}: {
  programs = {
    zsh = {
      enable = true;
    };
		k9s = {
			enable = true;
		};
  };
}
