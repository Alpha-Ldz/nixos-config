{ pkgs, config, lib, isLinux ? true, isDarwin ? false, ... }:
{
  programs.firefox = {
    # On macOS, install Firefox via Homebrew for better integration
    # On Linux, install via nixpkgs
    enable = isLinux;
    profiles.${config.home.username} = {
      settings = {
        # Follow system theme
        "layout.css.prefers-color-scheme.content-override" = 2;  # 2 = follow system
        "ui.systemUsesDarkTheme" = 1;  # Will be overridden by system

        # Enable dark mode for websites that support it
        "browser.theme.toolbar-theme" = 2;  # 0 = light, 1 = dark, 2 = system
        "browser.theme.content-theme" = 2;

        # Privacy-respecting dark mode detection
        "privacy.resistFingerprinting" = false;
      };

      # Optional: Custom userChrome.css for better theme integration
      userChrome = ''
        /* Auto-adjust Firefox UI based on system theme */
        @media (prefers-color-scheme: dark) {
          :root {
            --toolbar-bgcolor: #1e1e2e !important;
            --tab-selected-bgcolor: #313244 !important;
          }
        }

        @media (prefers-color-scheme: light) {
          :root {
            --toolbar-bgcolor: #f5f5f5 !important;
            --tab-selected-bgcolor: #ffffff !important;
          }
        }
      '';
    };
  };
}
