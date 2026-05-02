{ lib, ... }:
{
  # Linux-specific home configuration

  # XDG directories
  xdg.enable = true;

  # XCompose for US International keyboard with macOS/Windows cedilla behavior
  # Makes ' + c = ç instead of ć
  home.file.".XCompose".text = ''
    include "%L"

    <dead_acute> <c> : "ç" ccedilla
    <dead_acute> <C> : "Ç" Ccedilla
  '';

  # Home directory is set by user config in users/*/home.nix
}
