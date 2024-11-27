{ 
  pkgs, 
  ... 
}: {
	programs.neovim = 
		let
			toLua = str: "lua << EOF\n${str}\nEOF\n";
			toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
			in
			{
			enable = true;

			viAlias = true;
			vimAlias = true;
			vimdiffAlias = true;

			extraPackages = with pkgs; [
				lua-language-server
				xclip
				wl-clipboard
			];

			plugins = with pkgs.vimPlugins; [
				cmp_luasnip
				cmp-nvim-lsp
				lush-nvim
				nvim-cmp
				telescope-fzf-native-nvim
				luasnip
				{
					plugin = bluloco-nvim;
					config = toLuaFile ./plugin/bluloco.lua;
				}
				{
					plugin = nvim-cmp;
					config = toLuaFile ./plugin/cmp.lua;
				}
				{
					plugin = lualine-nvim;
					config = toLuaFile ./plugin/lualine.lua;
				}
				{
					plugin = telescope-nvim;
					config = toLuaFile ./plugin/telescope.lua;
				}
				{
					plugin = (nvim-treesitter.withPlugins (p: [
						p.tree-sitter-nix
						p.tree-sitter-vim
						p.tree-sitter-bash
						p.tree-sitter-lua
						p.tree-sitter-python
						p.tree-sitter-json
						p.tree-sitter-java
						p.tree-sitter-kotlin
						p.tree-sitter-yaml
						p.tree-sitter-json
					]));
					config = toLuaFile ./plugin/treesitter.lua;
				}
			];

			extraLuaConfig = ''
				${builtins.readFile ./options.lua}
			'';
		};
}
