vim.cmd('syntax spell toplevel')
vim.opt.spell = false
vim.cmd('filetype plugin indent on')

vim.filetype.add({
  extension = {
    logo = 'logo',
  },
})
