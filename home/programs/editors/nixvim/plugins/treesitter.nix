{pkgs, ...}:
{
  programs = {
    nixvim = {
      plugins = {
        treesitter = {
          enable = true;
          folding = false;
          settings = {
            indent.enable = true;
            highlight.enable = true;
          };
          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            bash
            python
            json
            lua
            make
            markdown
            nix
            regex
            toml
            vim
            vimdoc
            xml
            yaml
          ];
        };
      };
    };
  };
}
