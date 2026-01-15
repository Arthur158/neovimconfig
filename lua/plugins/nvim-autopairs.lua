
-- plugins/nvim-autopairs.lua

require('nvim-autopairs').setup {
  -- Your detailed nvim-autopairs configuration
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
}

-- Return from this file so it can be required successfully
return {}
