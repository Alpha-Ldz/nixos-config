local bluloco = require("bluloco")
bluloco.setup({
  style = "auto",               -- "auto" | "dark" | "light"
  transparent = false,
  italics = false,
  terminal = vim.fn.has("gui_running") == 1, -- bluoco colors are enabled in gui terminals per default.
  guicursor   = true,
})

vim.opt.termguicolors = true
vim.cmd('colorscheme bluloco')
