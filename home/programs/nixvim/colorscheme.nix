{pkgs, inputs, ...}: {
  programs = { 
    nixvim = {
      extraPlugins = [ 
        pkgs.vimPlugins.bluloco-nvim
        pkgs.vimPlugins.lush-nvim
      ];
      colorscheme = "bluloco";
    };
  };
}
