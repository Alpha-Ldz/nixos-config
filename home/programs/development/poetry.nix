{ pkgs, ... }:
{
  # Python development tools
  home.packages = with pkgs; [
    python313
    python313Packages.pip
    python313Packages.virtualenv
    poetry
    uv  # Fast Python package manager

    # Dépendances pour Camoufox/Playwright
    playwright-driver

    # Dépendances système pour Firefox/Camoufox
    xorg.libX11
    xorg.libXrandr
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    gtk3
    dbus
    glib
    nspr
    nss
    at-spi2-atk
    cups
    expat
    libdrm
    libxkbcommon
    mesa
    alsa-lib
    pango
    cairo

    # Pour mode headless (optionnel)
    xvfb-run
  ];

  # Variables d'environnement pour Playwright
  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };
}
