{pkgs, inputs, lib, isLinux ? true, ...}: {
  programs = {
    nixvim = {
      # Enable Wayland clipboard only on Linux
      clipboard.providers.wl-copy.enable = lib.mkIf isLinux true;

      # Set leader key to Space
      globals.mapleader = " ";
      globals.maplocalleader = " ";

      opts = {
        updatetime = 100; # faster completion
        number = true;
        relativenumber = true;

        autoindent = true;
        autowrite = true;
        autoread = true; # Auto reload files when changed externally
        confirm = true;
        clipboard = "unnamedplus";
        cursorline = true;
        list = true;
        expandtab = true;
        shiftround = true;
        shiftwidth = 2;
        # showmode = false;
        signcolumn = "yes";
        smartcase = true;
        smartindent = true;
        tabstop = 2;

        ignorecase = true;
        incsearch = true;
        completeopt = "menu,menuone,noselect";
        wildmode = "longest:full,full";
        mouse = ""; # Disable mouse

        swapfile = false;
        undofile = true; # Build-in persistent undo
        undolevels = 10000;
      };
    };
  };
}
