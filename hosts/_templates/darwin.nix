# Template for macOS with nix-darwin
{ pkgs, versions, ... }:
{
  # System packages - add your preferred tools
  environment.systemPackages = with pkgs; [
    vim
    git
    # Add more packages here
  ];

  # macOS system settings
  system = {
    # nix-darwin uses different versioning than NixOS
    # Latest stable version is 5
    stateVersion = 5;

    defaults = {
      # Dock settings
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
        # mru-spaces = false;  # Disable automatic space rearranging
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
        # FXPreferredViewStyle = "Nlsv";  # List view
        # ShowStatusBar = true;
      };

      # Global macOS preferences
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        # NSAutomaticCapitalizationEnabled = false;
        # NSAutomaticSpellingCorrectionEnabled = false;
      };

      # Trackpad settings
      # trackpad = {
      #   Clicking = true;  # Tap to click
      #   TrackpadRightClick = true;
      # };
    };

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  # Homebrew integration (optional)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # Uninstall packages not listed below
      upgrade = true;
    };

    # Command-line tools installed via Homebrew
    brews = [
      # Examples:
      # "llvm"
      # "cmake"
    ];

    # GUI applications installed via Homebrew Cask
    casks = [
      # Examples:
      # "firefox"
      # "visual-studio-code"
      # "docker"
      # "iterm2"
    ];

    # Mac App Store apps (requires mas-cli)
    # masApps = {
    #   "1Password" = 1333542190;
    # };
  };

  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    # Examples:
    # (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  # Shell configuration
  programs.zsh.enable = true;  # Default shell on macOS

  # CHANGE THIS - User configuration
  users.users.USERNAME = {
    name = "USERNAME";
    home = "/Users/USERNAME";
  };
}
