{
  programs.nixvim = {
    plugins.toggleterm = {
      enable = true;
      settings = {
        size = 20;
        open_mapping = "[[<C-\\>]]"; # Ctrl + \ pour toggle
        hide_numbers = true;
        shade_terminals = false; # Disable shading for transparency
        start_in_insert = true;
        insert_mappings = true; # Open terminal in insert mode
        terminal_mappings = true; # Apply mappings in terminal mode
        persist_size = true;
        persist_mode = true;
        direction = "horizontal"; # "horizontal", "vertical", "tab", or "float"
        close_on_exit = true;
        shell = "zsh";
        auto_scroll = true;
        float_opts = {
          border = "curved";
          winblend = 0;
          highlights = {
            border = "Normal";
            background = "Normal";
          };
        };
        highlights = {
          Normal = {
            link = "Normal";
          };
          NormalFloat = {
            link = "NormalFloat";
          };
        };
      };
    };

    keymaps = [
      # Toggle terminal
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>ToggleTerm<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Toggle terminal";
        };
      }
      # Terminal horizontal
      {
        mode = "n";
        key = "<leader>th";
        action = "<cmd>ToggleTerm direction=horizontal<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Terminal horizontal";
        };
      }
      # Terminal vertical
      {
        mode = "n";
        key = "<leader>tv";
        action = "<cmd>ToggleTerm direction=vertical size=80<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Terminal vertical";
        };
      }
      # Terminal flottant
      {
        mode = "n";
        key = "<leader>tf";
        action = "<cmd>ToggleTerm direction=float<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Terminal floating";
        };
      }
      # Escape terminal mode with ESC
      {
        mode = "t";
        key = "<Esc>";
        action = "<C-\\><C-n>";
        options = {
          noremap = true;
          silent = true;
          desc = "Exit terminal mode";
        };
      }
      # Navigate from terminal to other windows
      {
        mode = "t";
        key = "<C-h>";
        action = "<cmd>wincmd h<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to left window from terminal";
        };
      }
      {
        mode = "t";
        key = "<C-j>";
        action = "<cmd>wincmd j<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to bottom window from terminal";
        };
      }
      {
        mode = "t";
        key = "<C-k>";
        action = "<cmd>wincmd k<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to top window from terminal";
        };
      }
      {
        mode = "t";
        key = "<C-l>";
        action = "<cmd>wincmd l<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to right window from terminal";
        };
      }
    ];
  };
}
