{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(ccd5e5)";
          inner_color = "rgb(282c34)";
          outer_color = "rgb(10b0fe)";
          outline_thickness = 2;
          placeholder_text = ''<span foreground="##ccd5e5">Password...</span>'';
          shadow_passes = 2;
        }
      ];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b><big>$(date +"%H:%M")</big></b>"'';
          color = "rgb(ccd5e5)";
          font_size = 120;
          font_family = "Fira Code";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:18000000] echo "<b>$(date +"%A, %B %d")</b>"'';
          color = "rgb(ccd5e5)";
          font_size = 24;
          font_family = "Fira Code";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        # User
        {
          monitor = "";
          text = "    $USER";
          color = "rgb(ccd5e5)";
          font_size = 18;
          font_family = "Fira Code";
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Add hypridle for auto-locking
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300; # 5 minutes
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600; # 10 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
