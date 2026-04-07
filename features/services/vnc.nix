{ pkgs, ... }:
{
  # VNC client
  environment.systemPackages = with pkgs; [
    tigervnc  # includes vncviewer
  ];
}
