{
  config,
  pkgs,
  ...
}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        width = 50;
        spacing = 4;

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
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
      }

      #custom-launcher {
        font-size: 20px;
        color: #89b4fa;
        padding: 12px 0;
        margin: 8px 0;
      }

      #custom-launcher:hover {
        background: rgba(137, 180, 250, 0.2);
      }

      #workspaces {
        padding: 4px 0;
      }

      #workspaces button {
        padding: 4px;
        color: #6c7086;
        border-radius: 8px;
        min-width: 30px;
      }

      #workspaces button.active {
        color: #89b4fa;
        background: rgba(137, 180, 250, 0.2);
      }

      #workspaces button:hover {
        background: rgba(205, 214, 244, 0.1);
      }

      #window {
        font-size: 18px;
        padding: 8px 0;
        color: #89b4fa;
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
        color: #f38ba8;
      }

      #network {
        font-size: 16px;
        padding: 8px 0;
        color: #a6e3a1;
      }

      #network.disconnected {
        color: #f38ba8;
      }

      #bluetooth {
        font-size: 16px;
        padding: 8px 0;
        color: #89dceb;
      }

      #bluetooth.disabled {
        color: #6c7086;
      }

      #bluetooth.connected {
        color: #a6e3a1;
      }

      #battery {
        padding: 8px 0;
      }

      #battery.charging {
        color: #a6e3a1;
      }

      #battery.warning:not(.charging) {
        color: #f9e2af;
      }

      #battery.critical:not(.charging) {
        color: #f38ba8;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to {
          color: #181825;
        }
      }

      #pulseaudio {
        font-size: 16px;
        padding: 8px 0;
      }

      #pulseaudio.muted {
        color: #6c7086;
      }
    '';
  };
}
