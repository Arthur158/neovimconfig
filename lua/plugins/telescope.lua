require('telescope').load_extension('glyph')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<c-u>'] = false,
        ['<c-d>'] = false,
      },
    },
  },
}

pcall(require('telescope').load_extension, 'fzf')

require('config.telescope_utils').setup()
