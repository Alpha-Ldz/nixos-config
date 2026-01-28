{
  programs.nixvim = {
    enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<C-n>";
        action.__raw = ''
          function()
            local neotree_bufnr = nil
            local neotree_winid = nil

            -- Parcourir toutes les fenêtres pour trouver celle de Neo-tree
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
              if ft == 'neo-tree' then
                neotree_bufnr = buf
                neotree_winid = win
                break
              end
            end

            local current_win = vim.api.nvim_get_current_win()

            if neotree_winid == nil then
              -- Neo-tree n'est pas ouvert, l'ouvrir
              vim.cmd('Neotree filesystem reveal left')
            elseif neotree_winid ~= current_win then
              -- Neo-tree est ouvert mais pas focus, y mettre le focus
              vim.api.nvim_set_current_win(neotree_winid)
            else
              -- Neo-tree est ouvert et focus, le fermer
              vim.cmd('Neotree close')
            end
          end
        '';
        options = {
          noremap = true;
          silent = true;
          desc = "Basculer Neo-tree";
        };
      }
      {
        mode = "n";
        key = "<leader>f";
        action.__raw = ''
          function()
            vim.lsp.buf.format({ async = false })
          end
        '';
        options = {
          noremap = true;
          silent = true;
          desc = "Format current buffer";
        };
      }

      # Window management keymaps
      # Split windows
      {
        mode = "n";
        key = "<leader>sv";
        action = "<cmd>vsplit<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Split window vertically";
        };
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "<cmd>split<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Split window horizontally";
        };
      }
      {
        mode = "n";
        key = "<leader>sc";
        action = "<cmd>close<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Close current window";
        };
      }
      {
        mode = "n";
        key = "<leader>so";
        action = "<cmd>only<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Close all other windows";
        };
      }

      # Navigate between windows
      {
        mode = "n";
        key = "<leader>wh";
        action = "<C-w>h";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to left window";
        };
      }
      {
        mode = "n";
        key = "<leader>wj";
        action = "<C-w>j";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to bottom window";
        };
      }
      {
        mode = "n";
        key = "<leader>wk";
        action = "<C-w>k";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to top window";
        };
      }
      {
        mode = "n";
        key = "<leader>wl";
        action = "<C-w>l";
        options = {
          noremap = true;
          silent = true;
          desc = "Move to right window";
        };
      }

      # Resize windows
      {
        mode = "n";
        key = "<leader>w=";
        action = "<C-w>=";
        options = {
          noremap = true;
          silent = true;
          desc = "Equalize window sizes";
        };
      }
      {
        mode = "n";
        key = "<leader>w>";
        action = "<cmd>vertical resize +5<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Increase window width";
        };
      }
      {
        mode = "n";
        key = "<leader>w<";
        action = "<cmd>vertical resize -5<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Decrease window width";
        };
      }
      {
        mode = "n";
        key = "<leader>w+";
        action = "<cmd>resize +5<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Increase window height";
        };
      }
      {
        mode = "n";
        key = "<leader>w-";
        action = "<cmd>resize -5<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Decrease window height";
        };
      }
    ];
  };
}

