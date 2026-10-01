-- Leader keys must be set before lazy.nvim loads plugin specifications.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.lazy')
require('settings.options')
require('keymaps.telescope')
require('keymaps.mappings')
require('config.autocmds')
require('config.commands')
require('config.filetypes')

-- vim: ts=2 sts=2 sw=2 et
