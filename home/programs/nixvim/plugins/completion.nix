let
  selectOpts = "{behavior = cmp.SelectBehavior.Select}";
in
{pkgs, ...}: {
  programs = {
    nixvim = {
      plugins = {
        cmp = {
          enable = true;
          settings = {
            autoEnableSources = true;
            performance = {
              debounce = 150;
            };
            sources = [
              {name = "path";}
              {
                name = "nvim_lsp";
                keywordLength = 1;
              }
              {
                name = "buffer";
                keywordLength = 3;
              }
              {name = "supermaven";}
            ];

            snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
            formatting = {
              fields = [
                "menu"
                "abbr"
                "kind"
              ];
              format = ''
                function(entry, item)
                  local menu_icon = {
                    nvim_lsp = '[LSP]',
                    luasnip = '[SNIP]',
                    buffer = '[BUF]',
                    path = '[PATH]',
                  }

                  item.menu = menu_icon[entry.source.name]
                  return item
                end
              '';
            };

            mapping = {
              "<Up>" = "cmp.mapping.select_prev_item(${selectOpts})";
              "<Down>" = "cmp.mapping.select_next_item(${selectOpts})";

              "<C-p>" = "cmp.mapping.select_prev_item(${selectOpts})";
              "<C-n>" = "cmp.mapping.select_next_item(${selectOpts})";

              "<C-u>" = "cmp.mapping.scroll_docs(-4)";
              "<C-d>" = "cmp.mapping.scroll_docs(4)";

              "<C-e>" = "cmp.mapping.abort()";
              "<C-y>" = "cmp.mapping.confirm({select = true})";
              "<CR>" = "cmp.mapping.confirm({select = false})";

              "<C-f>" = ''
                cmp.mapping(
                  function(fallback)
                    if luasnip.jumpable(1) then
                      luasnip.jump(1)
                    else
                      fallback()
                    end
                  end,
                  { "i", "s" }
                )
              '';

              "<C-b>" = ''
                cmp.mapping(
                  function(fallback)
                    if luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end,
                  { "i", "s" }
                )
              '';

              "<Tab>" = ''
                cmp.mapping(
                  function(fallback)
                    local col = vim.fn.col('.') - 1

                    if cmp.visible() then
                      cmp.select_next_item(select_opts)
                    elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                      fallback()
                    else
                      cmp.complete()
                    end
                  end,
                  { "i", "s" }
                )
              '';

              "<S-Tab>" = ''
                cmp.mapping(
                  function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item(select_opts)
                    else
                      fallback()
                    end
                  end,
                  { "i", "s" }
                )
              '';
            };
            window = {
              completion = {
                border = "rounded";
                winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None";
                zindex = 1001;
                scrolloff = 0;
                colOffset = 0;
                sidePadding = 1;
                scrollbar = true;
              };
              documentation = {
                border = "rounded";
                winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None";
                zindex = 1001;
                maxHeight = 20;
              };
            };
          };
        };
        cmp-nvim-lsp.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        cmp-treesitter.enable = true;
        dap.enable = true;
        none-ls = {
          enable = true;
          sources.formatting = {
            black.enable = true;
            alejandra.enable = true;
            hclfmt.enable = true;
            just.enable = true;
            prettier.enable = true;
            # rubyfmt is broken on darwin-based systems
            rubyfmt.enable = (
              pkgs.stdenv.hostPlatform.system
              != "x86_64-darwin"
              && pkgs.stdenv.hostPlatform.system != "aarch64-darwin"
            );
            sqlformat.enable = true;
            stylua.enable = true;
            yamlfmt.enable = true;
          };
          sources.diagnostics = {
            trivy.enable = true;
            yamllint.enable = true;
          };
        };
        lsp = {
          enable = true;
          servers = {
            jsonls.enable = true;
            marksman.enable = true;
            nil_ls.enable = true;
            nixd.enable = true;
            yamlls.enable = true;
            taplo.enable = true;
            pylsp = {
              enable = true;
              settings.plugins = {
                black.enabled = true;
                flake8.enabled = true;
                isort.enabled = true;
                jedi.enabled = true;
                mccabe.enabled = true;
                pycodestyle.enabled = true;
                pydocstyle.enabled = true;
                pyflakes.enabled = true;
                pylint.enabled = true;
                rope.enabled = true;
                yapf.enabled = true;
              };
            };
            lua_ls = {
              enable = true;
              settings.telemetry.enable = false;
            };
          };
        };
      };
    };
  };
}
