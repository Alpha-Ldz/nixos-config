{pkgs, ...}: {
  programs.nixvim = {
    # Markdown preview plugin
    plugins.markdown-preview = {
      enable = true;

      settings = {
        # Browser to use for preview (auto, chrome, firefox, etc.)
        browser = "default";

        # Port for the preview server
        port = "8080";

        # Auto-start preview when entering markdown buffer
        auto_start = false;

        # Auto-close preview when leaving markdown buffer
        auto_close = true;

        # Refresh on save or when leaving insert mode
        refresh_slow = false;

        # Allow scripts in markdown (for mermaid, etc.)
        disable_sync_scroll = false;

        # Custom CSS
        # markdown_css = "";

        # Syntax highlighting theme
        highlight_css = ""; # Uses your Neovim colorscheme

        # Command to open browser
        # open_to_the_world = false;
      };
    };

    # Render markdown inline in Neovim (optional, for better viewing without browser)
    plugins.render-markdown = {
      enable = true;

      settings = {
        # Rendering options
        file_types = [ "markdown" ];

        # Code blocks
        code = {
          enabled = true;
          sign = true;
          style = "full";
          position = "left";
          width = "block";
        };

        # Headings
        heading = {
          enabled = true;
          sign = true;
          icons = [ "󰲡 " "󰲣 " "󰲥 " "󰲧 " "󰲩 " "󰲫 " ];
        };

        # Bullets
        bullet = {
          enabled = true;
          icons = [ "●" "○" "◆" "◇" ];
        };

        # Checkboxes
        checkbox = {
          enabled = true;
          unchecked = {
            icon = "󰄱 ";
          };
          checked = {
            icon = "󰱒 ";
          };
        };
      };
    };

    # Key mappings for markdown
    keymaps = [
      # Preview markdown in browser
      {
        mode = "n";
        key = "<leader>mp";
        action = "<cmd>MarkdownPreview<cr>";
        options = {
          desc = "Markdown Preview";
          silent = true;
        };
      }

      # Stop markdown preview
      {
        mode = "n";
        key = "<leader>ms";
        action = "<cmd>MarkdownPreviewStop<cr>";
        options = {
          desc = "Markdown Preview Stop";
          silent = true;
        };
      }

      # Toggle markdown preview
      {
        mode = "n";
        key = "<leader>mt";
        action = "<cmd>MarkdownPreviewToggle<cr>";
        options = {
          desc = "Markdown Preview Toggle";
          silent = true;
        };
      }
    ];

    # Extra packages needed for markdown preview
    extraPackages = with pkgs; [
      # For markdown-preview.nvim
      nodejs
    ];
  };
}
