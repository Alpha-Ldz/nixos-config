{ pkgs, ... }:
{
  # Import user configurations for this host
  users.users.peuleu = {
    isNormalUser = true;
    description = "Peuleu";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" ];
    shell = pkgs.zsh;
  };
}
