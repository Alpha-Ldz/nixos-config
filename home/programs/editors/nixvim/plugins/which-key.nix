{
  programs.nixvim.plugins.which-key = {
    enable = true;
    settings = {
      delay = 500; # Délai en ms avant d'afficher la popup
      icons = {
        breadcrumb = "»";
        separator = "➜";
        group = "+";
      };
      spec = [
        {
          __unkeyed-1 = "<leader>f";
          group = "Find/Format";
        }
        {
          __unkeyed-1 = "<leader>s";
          group = "Split";
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "Window";
        }
        {
          __unkeyed-1 = "<leader>t";
          group = "Terminal";
        }
        {
          __unkeyed-1 = "<leader>p";
          group = "Poetry";
        }
        {
          __unkeyed-1 = "<leader>l";
          group = "LSP";
        }
        {
          __unkeyed-1 = "<leader>d";
          group = "Diagnostics";
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "Code";
        }
        {
          __unkeyed-1 = "<leader>r";
          group = "Rename";
        }
      ];
    };
  };
}
