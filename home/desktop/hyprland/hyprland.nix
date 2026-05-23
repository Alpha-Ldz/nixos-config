{
  inputs,
  pkgs, 
  ...
} : {
  wayland.windowManager.hyprland = { 
    enable = true;
    systemd.variables = ["--all"];
    settings = {
      "$mod" = "SUPER";
      "$modS" = "SUPER SHIFT";
      bindm = [
        "$mod, mouse:272,movewindow"
        "$mod, mouse:273,resizewindow"
      ];
      bind =
        [
          # Windaube shortcuts
        "$mod, RETURN, exec, kitty -c ~/.config/kitty/kitty.conf"
        "$mod, F, exec, firefox"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, D, exec, rofi -show drun"
        "$mod, L, exec, hyprlock"
        "$mod, S, exec, systemctl suspend"
        "$mod, M, exit"
        "$mod, T, exec, toggle-theme"

        "$modS, left, movewindow, l"
        "$modS, right, movewindow, r"
        "$modS, up, movewindow, u"
        "$modS, down, movewindow, d"
          # Windaube Shift shortcuts
        "$modS, F, fullscreen"
        "$modS, Q, killactive"

        # Master layout controls
        "$mod, J, layoutmsg, cyclenext"
        "$mod, K, layoutmsg, cycleprev"
        "$modS, J, layoutmsg, swapnext"
        "$modS, K, layoutmsg, swapprev"
        "$mod, SPACE, layoutmsg, swapwithmaster"
        "$mod, equal, layoutmsg, addmaster"
        "$mod, minus, layoutmsg, removemaster"

        # Toggle entre layout master et dwindle
        "$mod, P, exec, hyprctl keyword general:layout \"$(hyprctl getoption general:layout | grep -q 'master' && echo 'dwindle' || echo 'master')\""
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$modS, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );

      input = {
        kb_layout = "us";
        kb_variant = "intl";
        follow_mouse = 0;  # Disable focus following mouse - use keyboard to switch windows
        touchpad.natural_scroll = "yes";
        sensitivity = 0;
      };

      general = {
        gaps_in = 10;
        gaps_out = 10;
        border_size = 2;
        no_border_on_floating = false;
        layout = "master";

        # Bluloco theme colors for borders
        "col.active_border" = "rgba(10b0feee) rgba(ff78f8ee) 45deg";  # Blue to magenta gradient
        "col.inactive_border" = "rgba(42444daa)";  # Gray
      };

      master = {
        # Configuration pour layout 25% / 50% / 25%
        new_status = "master";  # Les nouvelles fenêtres deviennent master par défaut
        mfact = 0.50;  # La fenêtre master prend 50% de l'écran
        orientation = "center";  # Fenêtre master au centre
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
      };

      cursor = {
        no_warps = true;  # Don't move cursor to center when switching windows
        inactive_timeout = 3;  # Hide cursor after 3 seconds of inactivity
      };

      decoration = {
        rounding = 8;

        active_opacity = 1.0;
        inactive_opacity = 1.0;

        blurls = [
          "gtk-layer-shell"
          "lockscreen"
        ];
      };

      animations = {
        enabled = true;
        bezier = [
          "fluent_decel, 0, 0.2, 0.4, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "easeinoutsine, 0.37, 0, 0.63, 1"
        ];

        animation = [
          "windowsIn, 1, 3, easeOutCubic, popin 30%"
          "windowsOut, 1, 3, fluent_decel, popin 70%"
          "fadeOut, 1, 1.7, easeOutCubic"
          "fadeSwitch, 0, 1, easeOutCirc"
          "fadeShadow, 1, 10, easeOutCirc"
          "fadeDim, 1, 4, fluent_decel"
          "border, 1, 2.7, easeOutCirc"
          "workspaces, 1, 3, easeOutCubic, fade"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      # Window rules for Firefox picture-in-picture
      windowrulev2 = [
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "keepaspectratio, title:^(Picture-in-Picture)$"
        "size 640 360, title:^(Picture-in-Picture)$"
        "move 100%-w-20 100%-w-20, title:^(Picture-in-Picture)$"
      ];

      monitor = "HDMI-A-2, 3840x1080, auto, 1";


    };
  };
}
