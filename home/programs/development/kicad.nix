{ pkgs, ... }:
{
  # KiCad - PCB design and Gerber file editor
  home.packages = with pkgs; [
    kicad              # Full KiCad suite for PCB design
    # kicad-small      # Alternative: lighter version without 3D viewer
  ];
}
