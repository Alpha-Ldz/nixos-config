{pkgs, ...}:
{
  programs = {
    nixvim = {
      plugins = {
        treesitter = {
          enable = true;
          folding = false;
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
#          settings = {
#            indent.enable = true;
#            auto_install = true;
#            ensure_installed = [
#              "git_config"
#              "git_rebase"
#              "gitattributes"
#              "gitcommit"
#              "gitignore"
#            ];
#          };
        };
      };
    };
  };
}
