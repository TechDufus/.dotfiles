-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1


require('techdufus.plugins.plugins')
require('techdufus.core.options')
require('techdufus.terminal')
require('techdufus.core.keymaps')
require('techdufus.core.autocommands')
require('techdufus.plugins.telescope')
require('techdufus.plugins.autopairs')
require('techdufus.statusline')
require('techdufus.nvim-tree')
require('techdufus.nvim-lightbulb')
require('techdufus.toggleterm')
require('techdufus.plugins.lsp.lsp')
require('techdufus.nvim-go')
require('techdufus.filetype')
require("techdufus.color_scheme")



