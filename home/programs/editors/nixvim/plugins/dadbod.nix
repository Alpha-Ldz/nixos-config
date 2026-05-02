{pkgs, ...}: {
  programs = {
    nixvim = {
      plugins = {
        # Database client plugin
        vim-dadbod = {
          enable = true;
        };
      };

      # Extra plugins that need to be added manually
      extraPlugins = with pkgs.vimPlugins; [
        vim-dadbod-ui
        vim-dadbod-completion
      ];

      # Configuration for dadbod-ui
      extraConfigLua = ''
        -- Dadbod UI configuration
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_show_database_icon = 1
        vim.g.db_ui_force_echo_notifications = 0
        vim.g.db_ui_win_position = 'left'
        vim.g.db_ui_winwidth = 30

        -- Auto-complete configuration for dadbod
        vim.api.nvim_create_autocmd("FileType", {
          pattern = {"sql", "mysql", "plsql"},
          callback = function()
            require('cmp').setup.buffer({
              sources = {
                { name = 'vim-dadbod-completion' },
                { name = 'buffer' },
              }
            })
          end,
        })

        -- Save database connections in ~/.local/share/db_ui/
        vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      '';

      # Keymaps for database operations
      keymaps = [
        {
          mode = "n";
          key = "<leader>db";
          action = "<cmd>DBUIToggle<CR>";
          options = {
            desc = "Toggle Database UI";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>df";
          action = "<cmd>DBUIFindBuffer<CR>";
          options = {
            desc = "Find Database Buffer";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dr";
          action = "<cmd>DBUIRenameBuffer<CR>";
          options = {
            desc = "Rename Database Buffer";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dq";
          action = "<cmd>DBUILastQueryInfo<CR>";
          options = {
            desc = "Last Query Info";
            silent = true;
          };
        }
      ];
    };
  };
}
