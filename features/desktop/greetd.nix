{ pkgs, lib, ... }:
{
  # Enable greetd with regreet
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = lib.mkForce ../../home/desktop/hyprland/wallpapers/bluloco-dark.png;
        fit = lib.mkForce "Cover";
      };
      GTK = {
        application_prefer_dark_theme = lib.mkForce true;
        cursor_theme_name = lib.mkForce "Adwaita";
        font_name = lib.mkForce "Fira Code 12";
        icon_theme_name = lib.mkForce "Adwaita";
        theme_name = lib.mkForce "Adwaita-dark";
      };
      commands = {
        reboot = lib.mkForce [ "systemctl" "reboot" ];
        poweroff = lib.mkForce [ "systemctl" "poweroff" ];
      };
    };
  };

  # Custom CSS styling for regreet with Bluloco theme
  environment.etc."greetd/regreet.css".text = ''
    * {
      font-family: "Fira Code", monospace;
      font-size: 14px;
    }

    window {
      background-color: #282c34;
    }

    /* Main login container */
    .container {
      background-color: rgba(40, 44, 52, 0.95);
      border-radius: 12px;
      padding: 40px;
      border: 2px solid #10b0fe;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
    }

    /* Labels */
    label {
      color: #ccd5e5;
    }

    /* Text entries (username/password) */
    entry {
      background-color: #1f2329;
      color: #ccd5e5;
      border: 1px solid #61697a;
      border-radius: 6px;
      padding: 10px;
      margin: 8px 0;
      caret-color: #10b0fe;
    }

    entry:focus {
      border-color: #10b0fe;
      outline: none;
      box-shadow: 0 0 0 2px rgba(16, 176, 254, 0.2);
    }

    entry::placeholder {
      color: #61697a;
    }

    /* Buttons */
    button {
      background-color: #10b0fe;
      color: #282c34;
      border: none;
      border-radius: 6px;
      padding: 10px 20px;
      margin: 8px 4px;
      font-weight: bold;
      transition: all 0.2s;
    }

    button:hover {
      background-color: #3fc4ff;
      box-shadow: 0 4px 12px rgba(16, 176, 254, 0.4);
    }

    button:active {
      background-color: #0d8bca;
    }

    /* Secondary buttons (session/power) */
    button.secondary {
      background-color: transparent;
      color: #10b0fe;
      border: 1px solid #10b0fe;
    }

    button.secondary:hover {
      background-color: rgba(16, 176, 254, 0.1);
    }

    /* Dropdown menus */
    combobox button {
      background-color: #1f2329;
      color: #ccd5e5;
      border: 1px solid #61697a;
    }

    combobox button:hover {
      background-color: #2a2f38;
      border-color: #10b0fe;
    }

    /* Error messages */
    .error {
      color: #fc6a67;
      font-weight: bold;
    }

    /* Welcome/header text */
    .header {
      font-size: 24px;
      font-weight: bold;
      color: #10b0fe;
      margin-bottom: 20px;
    }
  '';
}
