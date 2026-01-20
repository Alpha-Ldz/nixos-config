{pkgs, inputs, ...}: {
  programs = {
    nixvim = {
      extraPlugins = [
        pkgs.vimPlugins.bluloco-nvim
        pkgs.vimPlugins.lush-nvim
        pkgs.vimPlugins.catppuccin-nvim
      ];

      # Set initial colorscheme
      colorscheme = "bluloco";

      # Auto-detect and switch theme based on system preference
      extraConfigLua = ''
        -- Disable mouse
        vim.opt.mouse = ""

        -- Auto-save function
        local function auto_save()
          local buf = vim.api.nvim_get_current_buf()
          -- Only save if buffer is modified and has a file name
          if vim.api.nvim_buf_get_option(buf, 'modified') and
             vim.api.nvim_buf_get_name(buf) ~= "" and
             vim.api.nvim_buf_get_option(buf, 'buftype') == "" then
            vim.cmd('silent! write')
          end
        end

        -- Auto-save on various events
        vim.api.nvim_create_autocmd({"FocusLost", "BufLeave", "WinLeave", "InsertLeave", "TextChanged"}, {
          pattern = "*",
          callback = auto_save,
        })

        -- Auto-format on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*",
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })

        -- Function to detect system dark mode preference using darkman
        local function detect_system_theme()
          local handle = io.popen("darkman get 2>/dev/null")
          if handle then
            local result = handle:read("*a")
            handle:close()

            if result:match("dark") then
              vim.o.background = "dark"
              vim.cmd.colorscheme("bluloco")
            else
              vim.o.background = "light"
              vim.cmd.colorscheme("bluloco-light")
            end
          end
        end

        -- Detect theme on startup
        detect_system_theme()

        -- Auto-detect theme when focus is gained (optional)
        vim.api.nvim_create_autocmd("FocusGained", {
          pattern = "*",
          callback = function()
            detect_system_theme()
          end,
        })

        -- Enable transparency
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
      '';
    };
  };
}
