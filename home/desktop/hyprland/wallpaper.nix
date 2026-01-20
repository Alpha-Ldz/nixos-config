{ pkgs, config, ... }:
let
  # Helper script to set wallpaper with gowall + swww
  wallpaperScript = pkgs.writeShellScriptBin "set-wallpaper" ''
    #!/usr/bin/env bash

    # Usage: set-wallpaper [theme]
    # Usage: set-wallpaper <image-path> [theme]
    # Example: set-wallpaper bluloco-dark (switches to pre-converted bluloco-dark)
    # Example: set-wallpaper bluloco-light (switches to pre-converted bluloco-light)
    # Example: set-wallpaper ~/Pictures/wallpaper.jpg catppuccin-mocha

    WALLPAPER_DIR="$HOME/.local/share/wallpapers"

    # If only one argument and it's a theme name (not a file), use pre-converted wallpaper
    if [ $# -eq 1 ] && [ "$1" = "bluloco-dark" -o "$1" = "bluloco-light" ]; then
      THEME="$1"
      IMAGE_PATH="$WALLPAPER_DIR/$THEME.png"

      if [ ! -f "$IMAGE_PATH" ]; then
        echo "Error: Pre-converted wallpaper not found: $IMAGE_PATH"
        exit 1
      fi

      echo "Setting $THEME wallpaper..."
      ${pkgs.swww}/bin/swww img "$IMAGE_PATH" \
        --transition-type fade \
        --transition-duration 2

      echo "Wallpaper set successfully!"
      exit 0
    fi

    # Otherwise, convert a custom image
    IMAGE_PATH="$1"
    THEME="''${2:-bluloco-dark}"
    CONVERTED_PATH="$WALLPAPER_DIR/current-wallpaper.png"

    if [ -z "$IMAGE_PATH" ]; then
      echo "Usage: set-wallpaper [theme]"
      echo "       set-wallpaper <image-path> [theme]"
      echo ""
      echo "Quick theme switch: set-wallpaper bluloco-dark|bluloco-light"
      echo "Custom conversion: set-wallpaper image.jpg [theme]"
      echo "Available themes: run 'gowall list' to see all themes"
      exit 1
    fi

    if [ ! -f "$IMAGE_PATH" ]; then
      echo "Error: Image file not found: $IMAGE_PATH"
      exit 1
    fi

    # Create wallpaper directory if it doesn't exist
    mkdir -p "$WALLPAPER_DIR"

    # Check if theme exists (skip for bluloco since it's custom)
    if [ "$THEME" != "bluloco-dark" ] && [ "$THEME" != "bluloco-light" ] && [ "$THEME" != "none" ]; then
      if ! ${pkgs.gowall}/bin/gowall list | grep -q "$THEME"; then
        echo "Warning: Theme '$THEME' not found in gowall themes"
        echo "Using original image without conversion..."
        THEME="none"
      fi
    fi

    # Convert wallpaper with gowall if theme is specified
    if [ "$THEME" = "none" ]; then
      echo "Setting wallpaper without theme conversion..."
      cp "$IMAGE_PATH" "$CONVERTED_PATH"
    elif [ "$THEME" = "bluloco-dark" ] || [ "$THEME" = "bluloco-light" ]; then
      # For bluloco themes, convert using the custom JSON palette
      echo "Converting wallpaper to $THEME theme..."
      echo "Note: Make sure you have the $THEME.json file for proper conversion"
      echo "Using pre-converted $THEME wallpaper is recommended: set-wallpaper $THEME"
      ${pkgs.gowall}/bin/gowall convert "$IMAGE_PATH" --theme catppuccin-mocha --output "$CONVERTED_PATH"
    else
      echo "Converting wallpaper to $THEME theme..."
      ${pkgs.gowall}/bin/gowall convert "$IMAGE_PATH" --theme "$THEME" --output "$CONVERTED_PATH"
    fi

    # Set wallpaper with swww
    echo "Setting wallpaper with swww..."
    ${pkgs.swww}/bin/swww img "$CONVERTED_PATH" \
      --transition-type fade \
      --transition-duration 2

    echo "Wallpaper set successfully!"
    echo "Converted wallpaper saved to: $CONVERTED_PATH"
  '';
in
{
  # Install wallpaper packages
  home.packages = with pkgs; [
    gowall  # Image processing tool for theming wallpapers
    swww    # Wayland wallpaper daemon
    wallpaperScript  # Custom helper script
  ];

  # Configure swww to start with Hyprland and set default wallpaper
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${pkgs.swww}/bin/swww-daemon"
      # Wait for swww daemon to start, then set bluloco-dark wallpaper
      "${pkgs.bash}/bin/bash -c 'sleep 1 && ${pkgs.swww}/bin/swww img ~/.local/share/wallpapers/bluloco-dark.png --transition-type fade --transition-duration 2'"
    ];
  };

  # Create wallpaper directory and copy wallpapers
  home.file.".local/share/wallpapers/.keep".text = "";
  home.file.".local/share/wallpapers/default.jpg".source = ./wallpapers/default.jpg;
  home.file.".local/share/wallpapers/bluloco-dark.png".source = ./wallpapers/bluloco-dark.png;
  home.file.".local/share/wallpapers/bluloco-light.png".source = ./wallpapers/bluloco-light.png;
}
