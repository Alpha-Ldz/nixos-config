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

        local function apply_custom_highlights()
          vim.api.nvim_set_hl(0, "Normal",      { bg = "none" })
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
          vim.api.nvim_set_hl(0, "NormalNC",    { bg = "none" })
          vim.api.nvim_set_hl(0, "SignColumn",  { bg = "none" })
          vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
          vim.api.nvim_set_hl(0, "RainbowRed",    { fg = "#E06C75" })
          vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
          vim.api.nvim_set_hl(0, "RainbowBlue",   { fg = "#61AFEF" })
          vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
          vim.api.nvim_set_hl(0, "RainbowGreen",  { fg = "#98C379" })
          vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
          vim.api.nvim_set_hl(0, "RainbowCyan",   { fg = "#56B6C2" })
        end

        -- Use vim.schedule to apply AFTER all colorscheme autocmds (including ibl) finish
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "*",
          callback = function() vim.schedule(apply_custom_highlights) end,
        })

        -- Cache current theme to avoid reloading colorscheme on every FocusGained
        local current_theme = nil
        local function detect_system_theme()
          local handle = io.popen("darkman get 2>/dev/null")
          local new_theme = "dark"
          if handle then
            local result = handle:read("*a")
            handle:close()
            if not result:match("dark") then new_theme = "light" end
          end
          if new_theme == current_theme then return end
          current_theme = new_theme
          if new_theme == "dark" then
            vim.o.background = "dark"
            vim.cmd.colorscheme("bluloco")
          else
            vim.o.background = "light"
            vim.cmd.colorscheme("bluloco-light")
          end
        end

        detect_system_theme()

        vim.api.nvim_create_autocmd("FocusGained", {
          pattern = "*",
          callback = detect_system_theme,
        })
      '';
    };
  };
}
