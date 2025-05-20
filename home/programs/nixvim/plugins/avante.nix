{
  programs = {
    nixvim = {
      plugins = {
        avante = {
          enable = true;
          settings = {
            ollama = {
              # endpoint = "http://127.0.0.1:11434";
              model = "qwen2.5-coder:32b";
              # temperature = 0;
            };
            diff = {
              autojump = true;
              debug = false;
              list_opener = "copen";
            };
            highlights = {
              diff = {
                current = "DiffText";
                incoming = "DiffAdd";
              };
            };
            hints = {
              enabled = true;
            };
            mappings = {
              diff = {
                both = "cb";
                next = "]x";
                none = "c0";
                ours = "co";
                prev = "[x";
                theirs = "ct";
              };
            };
            provider = "ollama";
            windows = {
              sidebar_header = {
                align = "center";
                rounded = true;
              };
              width = 30;
              wrap = true;
            };
          };
        };
      };
    };
  };
}
