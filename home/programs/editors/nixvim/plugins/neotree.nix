{pkgs, ...}:
{
  programs = {
    nixvim = {
      extraConfigLua = ''
        local function neotree_fit_width()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].filetype ~= "neo-tree" then return end
          local winid = vim.api.nvim_get_current_win()
          local max_allowed = math.floor(vim.o.columns * 0.4)
          -- Step 1: expand wide so neo-tree renders full content
          vim.api.nvim_win_set_width(winid, max_allowed)
          -- Step 2: after neo-tree re-renders, measure and shrink to fit
          vim.schedule(function()
            if not vim.api.nvim_win_is_valid(winid) then return end
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local max_width = 30
            for _, line in ipairs(lines) do
              local w = vim.fn.strdisplaywidth(line)
              if w > max_width then max_width = w end
            end
            vim.api.nvim_win_set_width(winid, math.min(max_width + 2, max_allowed))
          end)
        end
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "neo-tree",
          callback = function()
            vim.keymap.set("n", "=", neotree_fit_width, { buffer = true, desc = "Resize to fit" })
          end,
        })
      '';

      plugins = {
        neo-tree = {
          enable = true;
          settings = {
            close_if_last_window = true;
            default_component_configs = {
              file_size.enabled = false;
              last_modified.enabled = false;
            };
            window = {
              width = 30;
              mappings = {
                "<cr>" = "open";
                "o" = "open";
              };
            };
            filesystem = {
              follow_current_file = {
                enabled = true;
              };
              use_libuv_file_watcher = true;
            };
            event_handlers = [
              {
                event = "file_opened";
                handler.__raw = ''
                  function(file_path)
                    -- Close neo-tree after opening a file
                    require("neo-tree.command").execute({ action = "close" })
                  end
                '';
              }
            ];
          };
        };
      };
    };
  };
}
