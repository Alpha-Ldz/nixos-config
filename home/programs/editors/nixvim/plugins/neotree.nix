{pkgs, ...}:
{
  programs = {
    nixvim = {
      plugins = {
        neo-tree = {
          enable = true;
          settings = {
            close_if_last_window = true;
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
