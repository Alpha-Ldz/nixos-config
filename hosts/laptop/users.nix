{ pkgs, ... }:
{
  # Import user configurations for this host
  users.users.peuleu = {
    isNormalUser = true;
    description = "Peuleu";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };
}
