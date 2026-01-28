{
  programs.nixvim = {
    # Auto-detect Poetry projects and set Python path
    autoCmd = [
      {
        event = ["VimEnter" "DirChanged"];
        pattern = "*";
        callback.__raw = ''
          function()
            local poetry_lock = vim.fn.findfile("poetry.lock", ".;")
            if poetry_lock ~= "" then
              local project_root = vim.fn.fnamemodify(poetry_lock, ":h")
              local venv_path = vim.fn.system("cd " .. project_root .. " && poetry env info --path 2>/dev/null"):gsub("%s+", "")

              if venv_path ~= "" and vim.fn.isdirectory(venv_path) == 1 then
                vim.g.python3_host_prog = venv_path .. "/bin/python"
                vim.notify("Poetry venv detected: " .. venv_path, vim.log.levels.INFO)
              end
            end
          end
        '';
      }
    ];

    keymaps = [
      # Poetry commands
      {
        mode = "n";
        key = "<leader>pi";
        action = "<cmd>ToggleTerm direction=horizontal<cr>poetry install<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Poetry install";
        };
      }
      {
        mode = "n";
        key = "<leader>pa";
        action.__raw = ''
          function()
            vim.ui.input({ prompt = "Package name: " }, function(input)
              if input then
                vim.cmd("ToggleTerm direction=horizontal")
                vim.api.nvim_feedkeys("poetry add " .. input .. "\n", "t", false)
              end
            end)
          end
        '';
        options = {
          noremap = true;
          silent = true;
          desc = "Poetry add package";
        };
      }
      {
        mode = "n";
        key = "<leader>pr";
        action.__raw = ''
          function()
            vim.ui.input({ prompt = "Package name: " }, function(input)
              if input then
                vim.cmd("ToggleTerm direction=horizontal")
                vim.api.nvim_feedkeys("poetry remove " .. input .. "\n", "t", false)
              end
            end)
          end
        '';
        options = {
          noremap = true;
          silent = true;
          desc = "Poetry remove package";
        };
      }
      {
        mode = "n";
        key = "<leader>pu";
        action = "<cmd>ToggleTerm direction=horizontal<cr>poetry update<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Poetry update";
        };
      }
      {
        mode = "n";
        key = "<leader>ps";
        action = "<cmd>ToggleTerm direction=horizontal<cr>poetry shell<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Poetry shell";
        };
      }
      {
        mode = "n";
        key = "<leader>pv";
        action = "<cmd>ToggleTerm direction=horizontal<cr>poetry env info<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Poetry env info";
        };
      }
    ];
  };
}
