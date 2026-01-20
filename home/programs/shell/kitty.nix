{config, pkgs, inputs, lib, isLinux ? true, ...}:
{
	programs.kitty = {
		enable = lib.mkIf isLinux true;

		font = {
			name = "Fira Code";
			size = 12;
		};

		settings = {
			window_padding_width = 5;
			backgroud_opacity = 1;
			dynamic_background_opacity = "yes";
			enable_audio_bell = "no";
			confirm_os_window_close = 0;
			allow_remote_control = "yes";
			listen_on = "unix:/tmp/kitty";
		};

		# Include dynamic theme file
		extraConfig = ''
			include ~/.config/kitty/current-theme.conf
		'';
	};

	# Include custom Bluloco theme files
	xdg.configFile."kitty/bluloco-dark.conf".source = ./bluloco-dark.conf;
	xdg.configFile."kitty/bluloco-light.conf".source = ./bluloco-light.conf;
}
