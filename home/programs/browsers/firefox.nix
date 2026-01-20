{ pkgs, config, lib, isLinux ? true, isDarwin ? false, ... }:
{
  programs.firefox = {
    # Install Firefox via Nix on both Linux and macOS
    enable = true;
    profiles.${config.home.username} = {
      settings = {
        # Enable userChrome.css customization
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Follow system theme
        "layout.css.prefers-color-scheme.content-override" = 2;  # 2 = follow system
        "ui.systemUsesDarkTheme" = 1;  # Will be overridden by system

        # Enable dark mode for websites that support it
        "browser.theme.toolbar-theme" = 2;  # 0 = light, 1 = dark, 2 = system
        "browser.theme.content-theme" = 2;

        # Privacy-respecting dark mode detection
        "privacy.resistFingerprinting" = false;
      };

      # Bluloco theme (Dark & Light) via userChrome.css
      userChrome = ''
        /* Bluloco Theme for Firefox - Auto-switching Dark/Light */

        /* Default: Bluloco Dark Color Palette */
        @media (prefers-color-scheme: dark) {
          :root {
            --bluloco-bg: #282c34 !important;
            --bluloco-fg: #cdd3e0 !important;
            --bluloco-blue: #10b0fe !important;
            --bluloco-yellow: #ffcc00 !important;
            --bluloco-red: #fc2e51 !important;
            --bluloco-green: #3fc56a !important;
            --bluloco-magenta: #ff78f8 !important;
            --bluloco-cyan: #5fb9bc !important;
            --bluloco-gray: #42444d !important;
            --bluloco-gray-light: #8f9aae !important;
            --bluloco-orange: #ff9369 !important;
            --bluloco-hover: #3a3f4b !important;
          }
        }

        /* Bluloco Light Color Palette */
        @media (prefers-color-scheme: light) {
          :root {
            --bluloco-bg: #f7f7f7 !important;
            --bluloco-fg: #38383a !important;
            --bluloco-blue: #0099e0 !important;
            --bluloco-yellow: #c5a231 !important;
            --bluloco-red: #d52652 !important;
            --bluloco-green: #239749 !important;
            --bluloco-magenta: #ce32c0 !important;
            --bluloco-cyan: #26608c !important;
            --bluloco-gray: #d3d3d3 !important;
            --bluloco-gray-light: #b9bac1 !important;
            --bluloco-orange: #df621b !important;
            --bluloco-hover: #e8e8e8 !important;
          }
        }

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
