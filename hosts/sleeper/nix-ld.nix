{ pkgs, ... }:
{
  # Enable nix-ld to run dynamically linked executables
  # Required for Playwright, Node.js binaries, and other dynamic executables
  programs.nix-ld.enable = true;

  # Libraries that will be available to dynamically linked executables
  programs.nix-ld.libraries = with pkgs; [
    # Base libraries
    stdenv.cc.cc
    zlib
    glibc

    # For Node.js and Playwright
    libgcc
    gcc-unwrapped

    # Graphics and display
    xorg.libX11
    xorg.libXrandr
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libxcb
    libxkbcommon

    # GTK and UI
    gtk3
    glib
    cairo
    pango
    gdk-pixbuf
    atk

    # Audio
    alsa-lib

    # System
    dbus
    nspr
    nss
    cups
    expat

    # Graphics drivers
    libdrm
    mesa

    # Other
    at-spi2-atk
    at-spi2-core
  ];
}
