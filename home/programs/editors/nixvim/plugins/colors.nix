{...}: {
  programs.nixvim = {
    # ibl HIGHLIGHT_SETUP hook fires before ibl renders, guaranteeing
    # rainbow groups are defined even after a colorscheme change
    extraConfigLua = ''
      local rainbow_colors = {
        RainbowRed    = "#E06C75",
        RainbowYellow = "#E5C07B",
        RainbowBlue   = "#61AFEF",
        RainbowOrange = "#D19A66",
        RainbowGreen  = "#98C379",
        RainbowViolet = "#C678DD",
        RainbowCyan   = "#56B6C2",
      }
      local function apply_rainbow()
        for name, color in pairs(rainbow_colors) do
          vim.api.nvim_set_hl(0, name, { fg = color })
        end
      end
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, apply_rainbow)
    '';

    plugins = {
      rainbow-delimiters = {
        enable = true;
        settings.highlight = [
          "RainbowRed"
          "RainbowYellow"
          "RainbowBlue"
          "RainbowOrange"
          "RainbowGreen"
          "RainbowViolet"
          "RainbowCyan"
        ];
      };

      indent-blankline = {
        enable = true;
        settings = {
          indent.highlight = [
            "RainbowRed"
            "RainbowYellow"
            "RainbowBlue"
            "RainbowOrange"
            "RainbowGreen"
            "RainbowViolet"
            "RainbowCyan"
          ];
          scope = {
            enabled = true;
            show_start = true;
            highlight = [
              "RainbowRed"
              "RainbowYellow"
              "RainbowBlue"
              "RainbowOrange"
              "RainbowGreen"
              "RainbowViolet"
              "RainbowCyan"
            ];
          };
        };
      };
    };
  };
}
