{
  programs.nixvim.plugins.telescope = {
    enable = true;

    keymaps = {
      # Find files
      "<leader>ff" = {
        action = "find_files";
        options = {
          desc = "Find files";
        };
      };

      # Live grep (search in files)
      "<leader>fg" = {
        action = "live_grep";
        options = {
          desc = "Live grep";
        };
      };

      # Grep current word under cursor
      "<leader>fw" = {
        action = "grep_string";
        options = {
          desc = "Grep word under cursor";
        };
      };

      # Recent files
      "<leader>fr" = {
        action = "oldfiles";
        options = {
          desc = "Recent files";
        };
      };

      # Buffers
      "<leader>fb" = {
        action = "buffers";
        options = {
          desc = "Find buffers";
        };
      };

      # Help tags
      "<leader>fh" = {
        action = "help_tags";
        options = {
          desc = "Help tags";
        };
      };

      # Git files
      "<leader>fgf" = {
        action = "git_files";
        options = {
          desc = "Git files";
        };
      };
    };

    settings = {
      defaults = {
        file_ignore_patterns = [
          "^.git/"
          "^.mypy_cache/"
          "^__pycache__/"
          "^output/"
          "^data/"
          "%.ipynb"
        ];
        set_env.COLORTERM = "truecolor";
      };
    };
  };
}
