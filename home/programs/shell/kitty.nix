{config, pkgs, inputs, ...}:
{
	programs.kitty = {
		enable = true;

		theme = "Bluloco Dark";

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
		};
	};
}
