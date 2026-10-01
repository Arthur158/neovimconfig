vim.g.floaterm_width = 0.8
vim.g.floaterm_height = 0.8
-- vim.g.floaterm_borderchars = '─│─│╭╮╯╰'
-- vim.g.floaterm_position = 'bottom'

vim.api.nvim_set_keymap('n', '<C-t>', ':FloatermToggle<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('t', '<C-t>', '<C-\\><C-n>:FloatermToggle<CR>', {noremap = true, silent = true})
