-- plugins/telescope.lua

require('telescope').setup {
  -- Your detailed telescope configuration
  -- For example, setting up pickers, defaults, extensions, etc.
  -- ...
}

-- Loading the telescope-fzf-native extension, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Additional telescope-related configurations or custom functions can go here

-- Return from this file so it can be required successfully
return {}

