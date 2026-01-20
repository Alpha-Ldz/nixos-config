# macOS host configuration with nix-darwin
{ pkgs, versions, ... }:
{
  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # macOS system settings
  system = {
    stateVersion = 5;  # nix-darwin uses different versioning than NixOS

    defaults = {
      # Dock settings
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };

      # NSGlobalDomain settings (macOS preferences)
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Set the primary user for system defaults
  system.primaryUser = "pierre-louis";

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  # Homebrew integration (optional but common on macOS)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    # Examples - customize as needed
    brews = [
      # "llvm"
    ];

    casks = [
      # "firefox"
      # "visual-studio-code"
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    # (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # User configuration
  users.users.pierre-louis = {
    name = "pierre-louis";
    home = "/Users/pierre-louis";
  };
}
