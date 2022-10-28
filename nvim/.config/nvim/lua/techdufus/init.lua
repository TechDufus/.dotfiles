-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1


require('techdufus.plugins')
require('techdufus.options')
require('techdufus.terminal')
require('techdufus.keymaps')
require('techdufus.autocommands')
require('techdufus.telescope')
require('techdufus.statusline')
require('techdufus.nvim-tree')
require('techdufus.toggleterm')
require('techdufus.lsp')
require('techdufus.nvim-go')
require('techdufus.filetype')
require('techdufus.commentary')



