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
    ];
  };
}

