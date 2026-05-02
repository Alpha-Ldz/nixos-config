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
                "<cr>" = {
                  __raw = ''
                    function(state)
                      local node = state.tree:get_node()
                      if node.type == "file" then
                        require("neo-tree.sources.filesystem.commands").open(state)
                        require("neo-tree.command").execute({ action = "close" })
                      else
                        require("neo-tree.sources.filesystem.commands").toggle_node(state)
                      end
                    end
                  '';
                };
                "o" = {
                  __raw = ''
                    function(state)
                      local node = state.tree:get_node()
                      if node.type == "file" then
                        require("neo-tree.sources.filesystem.commands").open(state)
                        require("neo-tree.command").execute({ action = "close" })
                      else
                        require("neo-tree.sources.filesystem.commands").toggle_node(state)
                      end
                    end
                  '';
                };
              };
            };
            filesystem = {
              follow_current_file = {
                enabled = true;
              };
              use_libuv_file_watcher = true;
            };
            event_handlers = [];
          };
        };
      };
    };
  };
}
