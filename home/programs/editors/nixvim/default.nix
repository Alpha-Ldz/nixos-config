{inputs, ...}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./options.nix
    ./plugins
    ./colorscheme.nix
    ./keymaps.nix
  ];
  programs = {
      nixvim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        luaLoader.enable = true;
    };
  };
}
