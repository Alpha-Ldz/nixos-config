{ pkgs, ... }:
let
  molten-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "molten-nvim";
    version = "2024-03-31";
    src = pkgs.fetchFromGitHub {
      owner = "benlubas";
      repo = "molten-nvim";
      rev = "c1db39e78fe18559d8f2204bf5c4d476bdc80d3e";
      hash = "sha256-FsDtd50Ehyd6EVdyU3fIDefkZJsOIi5bMPPdV3rKZw0=";
    };
    doCheck = false;
    meta.homepage = "https://github.com/benlubas/molten-nvim";
  };
in
{
  programs.nixvim = {
    extraPlugins = [ molten-nvim ];

    extraConfigLua = ''
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "kitty"
      vim.g.molten_output_win_max_height = 20
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>mi";
        action = "<cmd>MoltenInit<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Molten: Init kernel";
        };
      }
      {
        mode = "n";
        key = "<leader>mr";
        action = "<cmd>MoltenEvaluateLine<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Molten: Evaluate line";
        };
      }
      {
        mode = "v";
        key = "<leader>mr";
        action = ":<C-u>MoltenEvaluateVisual<cr>gv";
        options = {
          noremap = true;
          silent = true;
          desc = "Molten: Evaluate selection";
        };
      }
      {
        mode = "n";
        key = "<leader>mc";
        action = "<cmd>MoltenReevaluateCell<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Molten: Re-evaluate cell";
        };
      }
      {
        mode = "n";
        key = "<leader>md";
        action = "<cmd>MoltenDelete<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Molten: Delete cell";
        };
      }
      {
        mode = "n";
        key = "<leader>mo";
        action = "<cmd>MoltenShowOutput<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Molten: Show output";
        };
      }
      {
        mode = "n";
        key = "<leader>mh";
        action = "<cmd>MoltenHideOutput<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Molten: Hide output";
        };
      }
    ];

    # Python dependencies for molten
    extraPython3Packages = ps: with ps; [
      jupyter-client
      pillow
      cairosvg
      pynvim
      pnglatex
      plotly
      pyperclip
    ];
  };
}
