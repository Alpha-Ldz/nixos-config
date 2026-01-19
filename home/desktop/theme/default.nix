{
  config,
  pkgs,
  lib,
  ...
}: let
  # Theme switching script for light mode
  lightModeScript = pkgs.writeShellScript "light-mode" ''
    # Switch Kitty theme by updating symlink
    ln -sf ~/.config/kitty/bluloco-light.conf ~/.config/kitty/current-theme.conf

    # Reload all kitty instances
    ${pkgs.kitty}/bin/kitty @ --to unix:/tmp/kitty load-config || true

    # Switch Waybar (reload to apply new styles)
    pkill -SIGUSR2 waybar || true

    # Notify user
    ${pkgs.libnotify}/bin/notify-send "Theme" "Switched to light mode" -i weather-clear || true
  '';

  # Theme switching script for dark mode
  darkModeScript = pkgs.writeShellScript "dark-mode" ''
    # Switch Kitty theme by updating symlink
    ln -sf ~/.config/kitty/bluloco-dark.conf ~/.config/kitty/current-theme.conf

    # Reload all kitty instances
    ${pkgs.kitty}/bin/kitty @ --to unix:/tmp/kitty load-config || true

    # Switch Waybar (reload to apply new styles)
    pkill -SIGUSR2 waybar || true

    # Notify user
    ${pkgs.libnotify}/bin/notify-send "Theme" "Switched to dark mode" -i weather-clear-night || true
  '';
in {
  # Install darkman and required packages
  home.packages = with pkgs; [
    darkman
    libnotify
  ];

  # GTK theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Darkman service configuration
  systemd.user.services.darkman = {
    Unit = {
      Description = "Darkman system-wide dark mode manager";
      PartOf = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.darkman}/bin/darkman run";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Create darkman config directory and scripts
  home.file.".local/share/light-mode.d/light-mode.sh" = {
    source = lightModeScript;
    executable = true;
  };

  home.file.".local/share/dark-mode.d/dark-mode.sh" = {
    source = darkModeScript;
    executable = true;
  };

  # Darkman configuration
  xdg.configFile."darkman/config.yaml".text = ''
    lat: 48.8566
    lng: 2.3522
    useLocation: true
  '';
}
