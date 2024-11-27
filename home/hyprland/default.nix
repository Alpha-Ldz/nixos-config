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
        "$mod, M, exit"

        "$modS, left, movewindow, l"
        "$modS, right, movewindow, r"
        "$modS, up, movewindow, u"
        "$modS, down, movewindow, d"
          # Windaube Shift shortcuts
        "$modS, F, fullscreen"
        "$modS, Q, killactive"
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
        follow_mouse = 1;
        touchpad.natural_scroll = "yes";
        sensitivity = 0;
      };

      general = {
        gaps_in = 10;
        gaps_out = 10;
        border_size = 0;
        no_border_on_floating = true;
        layout = "dwindle";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
      };

      decoration = {
        rounding = 8;

        active_opacity = 1.0;
        inactive_opacity = 1.0;

        drop_shadow = true;
        shadow_ignore_window = true;
        shadow_offset = "2 2";
        shadow_range = 4;
        shadow_render_power = 2;
        "col.shadow" = "0x66000000";

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

      gestures = {
        workspace_swipe = "off";
      };

      windowrule = [
        "float,^(rofi)$"
      ];

    };
  };
}
