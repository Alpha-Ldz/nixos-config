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
    for socket in /tmp/kitty-*; do
      if [ -S "$socket" ]; then
        ${pkgs.kitty}/bin/kitty @ --to "unix:$socket" load-config || true
      fi
    done

    # Switch Waybar theme
    ln -sf ~/.config/waybar/waybar-light.css ~/.config/waybar/current-theme.css
    systemctl --user restart waybar || true

    # Switch wallpaper
    ${pkgs.swww}/bin/swww img ~/.local/share/wallpapers/bluloco-light.png \
      --transition-type fade \
      --transition-duration 2 || true

    # Set GTK color scheme preference (Firefox uses prefers-color-scheme media query)
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"

    # Notify user
    ${pkgs.libnotify}/bin/notify-send "Theme" "Switched to light mode" -i weather-clear || true
  '';

  # Theme toggle script
  toggleThemeScript = pkgs.writeShellScriptBin "toggle-theme" ''
    #!/usr/bin/env bash

    # Get current theme from darkman
    CURRENT=$(${pkgs.darkman}/bin/darkman get)

    if [ "$CURRENT" = "dark" ]; then
      echo "Switching to light mode..."
      ${pkgs.darkman}/bin/darkman set light
    else
      echo "Switching to dark mode..."
      ${pkgs.darkman}/bin/darkman set dark
    fi
  '';

  # Theme switching script for dark mode
  darkModeScript = pkgs.writeShellScript "dark-mode" ''
    # Switch Kitty theme by updating symlink
    ln -sf ~/.config/kitty/bluloco-dark.conf ~/.config/kitty/current-theme.conf

    # Reload all kitty instances
    for socket in /tmp/kitty-*; do
      if [ -S "$socket" ]; then
        ${pkgs.kitty}/bin/kitty @ --to "unix:$socket" load-config || true
      fi
    done

    # Switch Waybar theme
    ln -sf ~/.config/waybar/waybar-dark.css ~/.config/waybar/current-theme.css
    systemctl --user restart waybar || true

    # Switch wallpaper
    ${pkgs.swww}/bin/swww img ~/.local/share/wallpapers/bluloco-dark.png \
      --transition-type fade \
      --transition-duration 2 || true

    # Set GTK color scheme preference (Firefox uses prefers-color-scheme media query)
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

    # Notify user
    ${pkgs.libnotify}/bin/notify-send "Theme" "Switched to dark mode" -i weather-clear-night || true
  '';
in {
  # Install darkman and required packages
  home.packages = with pkgs; [
    darkman
    libnotify
    dconf
    toggleThemeScript
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
