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
        # Navigation et informations
        "gd" = "definition";
        "gD" = "declaration";
        "gi" = "implementation";
        "gr" = "references";
        "gt" = "type_definition";
        "K" = "hover";
        "<C-k>" = "signature_help";

        # Actions
        "<leader>rn" = "rename";
        "<leader>ca" = "code_action";
      };
    };

    keymaps = [
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
