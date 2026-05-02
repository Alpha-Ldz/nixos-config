{inputs, pkgs, ...}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
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

        extraPackages = with pkgs; [
          ripgrep  # Required for telescope live_grep

          # Python LSP and tools
          (python3.withPackages (ps: with ps; [
            python-lsp-server
            pylsp-mypy
            python-lsp-black
            pyls-isort
            pylsp-rope
            python-lsp-ruff
          ]))
        ];
    };
  };
}
