{
  programs.nixvim = {
    plugins.auto-save = {
      enable = true;
      settings = {
        enabled = true;
        trigger_events = {
          immediate_save = ["BufLeave" "FocusLost"];
          defer_save = ["InsertLeave" "TextChanged"];
          cancel_deferred_save = ["InsertEnter"];
        };
        condition = ''
          function(buf)
            local fn = vim.fn
            local utils = require("auto-save.utils.data")

            if fn.getbufvar(buf, "&modifiable") == 1 and
              utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
              return true
            end
            return false
          end
        '';
        write_all_buffers = false;
        debounce_delay = 135;
      };
    };

    # Auto-reload files when changed on disk
    autoCmd = [
      {
        event = ["FocusGained" "BufEnter" "CursorHold" "CursorHoldI"];
        pattern = "*";
        command = "if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif";
      }
      {
        event = "FileChangedShellPost";
        pattern = "*";
        command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None";
      }
    ];
  };
}
