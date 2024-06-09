-- plugins/nvim-tree.lua

require('nvim-tree').setup {
  -- Your Nvim Tree configuration here
  disable_netrw = true,
  update_cwd = true,
  diagnostics = {
    enable = true,
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  -- ... (other nvim-tree configurations)
}

-- Return from this file so it can be required successfully
return {}

