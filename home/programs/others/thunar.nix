{pkgs, lib, isLinux ? true, ...}:
{
  home.packages = lib.optionals isLinux (with pkgs; [
    xfce.thunar
    xfce.thunar-volman        # gestion des volumes/clés USB
    xfce.thunar-archive-plugin # support des archives
    xfce.tumbler              # aperçu des images/vidéos
  ]);
}
