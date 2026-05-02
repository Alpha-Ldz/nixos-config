{ pkgs, ... }:
{
  # CUDA development environment variables
  # These are set at user level, not system-wide
  home.sessionVariables = {
    # Add libc, NVIDIA, and X11 libraries to LD_LIBRARY_PATH
    # X11 libraries needed for OpenCV (cv2) used by ultralytics/YOLO
    LD_LIBRARY_PATH = builtins.concatStringsSep ":" [
      "${pkgs.stdenv.cc.cc.lib}/lib"
      "/run/opengl-driver/lib"
      "${pkgs.xorg.libxcb}/lib"
      "${pkgs.xorg.libX11}/lib"
      "${pkgs.xorg.libXext}/lib"
      "${pkgs.xorg.libXrender}/lib"
      "${pkgs.libGL}/lib"
      "${pkgs.glib.out}/lib"
      "${pkgs.zlib}/lib"
    ];
  };

  # Optional: Install CUDA toolkit if needed
  # home.packages = with pkgs; [
  #   cudatoolkit
  # ];
}
