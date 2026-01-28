{ pkgs, config, lib, isLinux ? true, isDarwin ? false, ... }:
{
  # Deploy Firefox theme CSS files to profile chrome directory
  home.file.".mozilla/firefox/${config.home.username}/chrome/firefox-dark.css".source = ./firefox-dark.css;
  home.file.".mozilla/firefox/${config.home.username}/chrome/firefox-light.css".source = ./firefox-light.css;

  # Create initial theme symlink (default to dark theme)
  home.activation.firefoxTheme = config.lib.dag.entryAfter ["writeBoundary"] ''
    FIREFOX_CHROME_DIR="${config.home.homeDirectory}/.mozilla/firefox/${config.home.username}/chrome"
    if [ -d "$FIREFOX_CHROME_DIR" ]; then
      $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
        "$FIREFOX_CHROME_DIR/firefox-dark.css" \
        "$FIREFOX_CHROME_DIR/firefox-current-theme.css"
    fi
  '';

  programs.firefox = {
    # Install Firefox via Nix on both Linux and macOS
    enable = true;
    profiles.${config.home.username} = {
      settings = {
        # Enable userChrome.css customization
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Follow system theme
        "layout.css.prefers-color-scheme.content-override" = 2;  # 2 = follow system

        # Enable system theme detection for toolbar and content
        "browser.theme.toolbar-theme" = 2;  # 0 = light, 1 = dark, 2 = system
        "browser.theme.content-theme" = 2;

        # Privacy-respecting dark mode detection
        "privacy.resistFingerprinting" = false;

        # Session restore settings for seamless theme switching
        "browser.startup.page" = 3;  # Restore previous session
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.max_tabs_undo" = 25;
        "browser.sessionstore.max_windows_undo" = 3;
      };

      # Bluloco theme (Dark & Light) via userChrome.css
      userChrome = ''
        /* Bluloco Theme for Firefox - Dynamic theme switching */
        @import url("firefox-current-theme.css");

        :root {
          /* Apply bluloco colors to Firefox UI */
          --toolbar-bgcolor: var(--bluloco-bg) !important;
          --toolbar-color: var(--bluloco-fg) !important;
          --lwt-accent-color: var(--bluloco-bg) !important;
          --lwt-text-color: var(--bluloco-fg) !important;

          /* Tabs */
          --tab-selected-bgcolor: var(--bluloco-gray) !important;
          --tab-selected-textcolor: var(--bluloco-fg) !important;
          --tab-bgcolor: var(--bluloco-bg) !important;
          --tab-hover-bgcolor: var(--bluloco-hover) !important;

          /* URL bar */
          --urlbar-box-bgcolor: var(--bluloco-gray) !important;
          --urlbar-box-text-color: var(--bluloco-fg) !important;
          --urlbar-box-focus-bgcolor: var(--bluloco-gray) !important;

          /* Sidebar */
          --sidebar-background-color: var(--bluloco-bg) !important;
          --sidebar-text-color: var(--bluloco-fg) !important;
          --sidebar-border-color: var(--bluloco-gray) !important;

          /* Popups and dropdowns */
          --panel-background: var(--bluloco-bg) !important;
          --panel-color: var(--bluloco-fg) !important;
          --panel-separator-color: var(--bluloco-gray) !important;

          /* Buttons */
          --button-bgcolor: var(--bluloco-gray) !important;
          --button-hover-bgcolor: var(--bluloco-blue) !important;
          --button-active-bgcolor: var(--bluloco-blue) !important;

          /* Links and accents */
          --lwt-tab-line-color: var(--bluloco-blue) !important;
          --focus-outline-color: var(--bluloco-blue) !important;
        }

        /* Toolbar customization */
        #nav-bar {
          background: var(--bluloco-bg) !important;
          color: var(--bluloco-fg) !important;
          border: none !important;
        }

        /* Tab styling */
        .tabbrowser-tab[selected="true"] .tab-background {
          background: var(--bluloco-gray) !important;
          border-top: 2px solid var(--bluloco-blue) !important;
        }

        .tabbrowser-tab:not([selected]):hover .tab-background {
          background: var(--bluloco-hover) !important;
        }

        .tab-text {
          color: var(--bluloco-fg) !important;
        }

        /* URL bar styling */
        #urlbar, #searchbar {
          background-color: var(--bluloco-gray) !important;
          color: var(--bluloco-fg) !important;
          border: 1px solid var(--bluloco-gray) !important;
        }

        #urlbar:focus-within, #searchbar:focus-within {
          border-color: var(--bluloco-blue) !important;
          box-shadow: 0 0 0 1px var(--bluloco-blue) !important;
        }

        /* Sidebar styling */
        #sidebar-box {
          background-color: var(--bluloco-bg) !important;
          color: var(--bluloco-fg) !important;
        }

        /* Context menus and panels */
        menupopup, panel {
          background-color: var(--bluloco-bg) !important;
          color: var(--bluloco-fg) !important;
          border: 1px solid var(--bluloco-gray) !important;
        }

        menuitem:hover, menu:hover {
          background-color: var(--bluloco-gray) !important;
        }

        /* Scrollbars */
        scrollbar {
          background-color: var(--bluloco-bg) !important;
        }

        thumb {
          background-color: var(--bluloco-gray-light) !important;
        }

        thumb:hover {
          background-color: var(--bluloco-blue) !important;
        }
      '';
    };
  };
}
