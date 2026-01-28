{
  config,
  pkgs,
  ...
}: {
  # Deploy waybar theme files
  xdg.configFile."waybar/waybar-dark.css".source = ./waybar-dark.css;
  xdg.configFile."waybar/waybar-light.css".source = ./waybar-light.css;

  # Create initial theme symlink (default to dark theme)
  home.activation.waybarTheme = config.lib.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
      ${config.xdg.configHome}/waybar/waybar-dark.css \
      ${config.xdg.configHome}/waybar/current-theme.css
  '';

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        width = 50;
        spacing = 4;
        output = ["DP-2"];  # Show only on first monitor

        modules-left = [
          "hyprland/workspaces"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          # "tray"
          # "network"
          # "bluetooth"
          "battery"
          # "pulseaudio"
        ];

        # Custom launcher button
        "custom/launcher" = {
          format = "";
          on-click = "rofi -show drun";
          tooltip = false;
        };

        # Workspaces module
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            active = "";
            default = "";
          };
          persistent-workspaces = {
            "*" = 5; # Show 5 workspaces
          };
          on-click = "activate";
        };

        # Window title module
        "hyprland/window" = {
          format = "{}";
          max-length = 3;
          separate-outputs = true;
          rewrite = {
            "(.*) — Mozilla Firefox" = "";
            "(.*) - Visual Studio Code" = "";
            "kitty" = "";
            "nvim (.*)" = "";
            "" = "";
          };
        };

        # Clock module
        "clock" = {
          format = "{:%H\n%M}";
          format-alt = "{:%a\n%d\n%b}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        # System tray
        "tray" = {
          icon-size = 16;
          spacing = 8;
        };

        # Network module
        "network" = {
          format-wifi = "";
          format-ethernet = "";
          format-disconnected = "";
          tooltip-format = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ipaddr}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "nm-connection-editor";
        };

        # Bluetooth module
        "bluetooth" = {
          format = "";
          format-disabled = "";
          format-connected = "";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{device_alias} {device_battery_percentage}%";
          on-click = "blueman-manager";
        };

        # Battery module
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-charging = "󰂄";
          format-plugged = "󰂄";
          format-alt = "{capacity}%";
          format-icons = ["" "" "" "" ""];
          tooltip-format = "{capacity}% {timeTo}";
        };

        # Pulseaudio module
        "pulseaudio" = {
          format = "{icon}";
          format-muted = "";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
          tooltip-format = "{volume}%";
        };
      };
    };

    style = ''
      @import url("file:///home/peuleu/.config/waybar/current-theme.css");

      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: @waybar-bg;
        color: @waybar-fg;
        border-radius: 10px;
        margin-top: 10px;
        margin-bottom: 10px;
        margin-left: 10px;
      }

      #custom-launcher {
        font-size: 20px;
        color: @waybar-blue;
        padding: 12px 0;
        margin: 8px 0;
      }

      #custom-launcher:hover {
        background: @waybar-blue-hover;
      }

      #workspaces {
        padding: 4px 0;
      }

      #workspaces button {
        padding: 4px;
        color: @waybar-gray;
        border-radius: 8px;
        min-width: 30px;
      }

      #workspaces button.active {
        color: @waybar-blue;
        background: @waybar-blue-hover;
      }

      #workspaces button:hover {
        background: @waybar-hover;
      }

      #window {
        font-size: 18px;
        padding: 8px 0;
        color: @waybar-blue;
      }

      #clock {
        font-size: 16px;
        font-weight: bold;
        padding: 8px 0;
      }

      #tray {
        padding: 8px 0;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        color: @waybar-red;
      }

      #network {
        font-size: 16px;
        padding: 8px 0;
        color: @waybar-green;
      }

      #network.disconnected {
        color: @waybar-red;
      }

      #bluetooth {
        font-size: 16px;
        padding: 8px 0;
        color: @waybar-cyan;
      }

      #bluetooth.disabled {
        color: @waybar-gray;
      }

      #bluetooth.connected {
        color: @waybar-green;
      }

      #battery {
        padding: 8px 0;
      }

      #battery.charging {
        color: @waybar-green;
      }

      #battery.warning:not(.charging) {
        color: @waybar-yellow;
      }

      #battery.critical:not(.charging) {
        color: @waybar-red;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to {
          color: @waybar-bg-alt;
        }
      }

      #pulseaudio {
        font-size: 16px;
        padding: 8px 0;
      }

      #pulseaudio.muted {
        color: @waybar-gray;
      }
    '';
  };
}
