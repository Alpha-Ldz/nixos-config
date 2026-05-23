{
  programs.nixvim = {
    plugins.lsp.keymaps = {
      diagnostic = {
        # Navigation dans les diagnostics (erreurs/warnings)
        "<leader>dn" = "goto_next";
        "<leader>dp" = "goto_prev";
        "<leader>dl" = "open_float";
        "<leader>dq" = "setloclist";
      };

      lspBuf = {
        # These stay as default (don't need window reuse)
        "gr" = "references";
        "K" = "hover";
        "<C-k>" = "signature_help";

        # Actions
        "<leader>rn" = "rename";
        "<leader>ca" = "code_action";
      };
    };

    keymaps = let
      # Helper to create LSP goto keymap with window reuse
      mkLspGoto = key: method: desc: {
        mode = "n";
        inherit key;
        action.__raw = ''
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then return end
            local encoding = clients[1].offset_encoding or "utf-16"
            local params = vim.lsp.util.make_position_params(0, encoding)
            vim.lsp.buf_request(0, '${method}', params, function(err, result, ctx, config)
              if err or not result or vim.tbl_isempty(result) then
                vim.notify("No result found", vim.log.levels.INFO)
                return
              end

              local target = result
              if vim.islist(result) then
                target = result[1]
              end

              local uri = target.uri or target.targetUri
              local range = target.range or target.targetSelectionRange

              if not uri then return end

              local target_bufnr = vim.uri_to_bufnr(uri)
              local target_path = vim.uri_to_fname(uri)

              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local win_buf = vim.api.nvim_win_get_buf(win)
                if win_buf == target_bufnr or vim.api.nvim_buf_get_name(win_buf) == target_path then
                  vim.api.nvim_set_current_win(win)
                  if range then
                    vim.api.nvim_win_set_cursor(win, {range.start.line + 1, range.start.character})
                  end
                  return
                end
              end

              vim.lsp.util.jump_to_location(target, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
            end)
          end
        '';
        options = { noremap = true; silent = true; desc = "${desc} (reuse window)"; };
      };
    in [
      # LSP goto with window reuse
      (mkLspGoto "gd" "textDocument/definition" "Go to definition")
      (mkLspGoto "gD" "textDocument/declaration" "Go to declaration")
      (mkLspGoto "gi" "textDocument/implementation" "Go to implementation")
      (mkLspGoto "gt" "textDocument/typeDefinition" "Go to type definition")
      # LSP Info
      {
        mode = "n";
        key = "<leader>li";
        action = "<cmd>LspInfo<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "LSP Info";
        };
      }
      {
        mode = "n";
        key = "<leader>lr";
        action = "<cmd>LspRestart<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "LSP Restart";
        };
      }
      {
        mode = "n";
        key = "<leader>ls";
        action = "<cmd>LspStart<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "LSP Start";
        };
      }
      # Telescope LSP
      {
        mode = "n";
        key = "<leader>fd";
        action = "<cmd>Telescope diagnostics<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Find diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = "<cmd>Telescope lsp_document_symbols<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Find document symbols";
        };
      }
    ];
  };
}
