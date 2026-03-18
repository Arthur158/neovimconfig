local api = require('codecompanion')

api.setup({
  display = {
    action_palette = {
      provider = "telescope",
    },
  },
})

-- Keymaps

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

local wk = require('which-key')
wk.add({
  mode = { 'n', 'v' },
  -- { '<C-a>', "<cmd>CodeCompanionActions<cr>", desc = 'Code Companion' },
  -- { '<leader>a', "<cmd>CodeCompanionChat Toggle<cr>", desc = 'CodeCompanion Ch[a]t Toggle' },
})

wk.add({
  mode = { 'v' },
  -- { 'ga', "<cmd>CodeCompanionChat Add<cr>", desc = 'CodeCompanion [A]ctions Add' },
})
