local api = require('codecompanion')

api.setup({
  adapters = {
    http = {
      anthropic = function()
        return require('codecompanion.adapters').extend('anthropic', {
          url = '${base_url}/v1/messages',
          env = {
            base_url = 'ANTHROPIC_BASE_URL',
          },
          schema = {
            model = {
              default = 'fable',
              choices = {
                fable = { formatted_name = 'fable' },
              },
            },
          },
        })
      end,
    },
  },
  interactions = {
    chat = {
      adapter = "anthropic",
      model = "fable",
    },
    inline = {
      adapter = "anthropic",
      model = "fable",
    },
    cli = {
      agent = "claude_code",
      agents = {
        claude_code = {
          cmd = "claude",
          args = {},
          description = "Claude Code CLI",
          provider = "terminal",
        },
      },
    },
  },
  display = {
    action_palette = {
      provider = "telescope",
    },
  },
})

-- Keymaps

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

vim.keymap.set('n', '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', {
  silent = true,
  desc = 'CodeCompanion chat',
})
vim.keymap.set('n', '<leader>ct', '<cmd>CodeCompanionCLI<cr>', {
  silent = true,
  desc = 'Claude Code terminal',
})
vim.keymap.set({ 'n', 'v' }, '<leader>cx', '<cmd>CodeCompanionActions<cr>', {
  silent = true,
  desc = 'CodeCompanion actions',
})
vim.keymap.set('v', '<leader>cs', '<cmd>CodeCompanionChat Add<cr>', {
  silent = true,
  desc = 'CodeCompanion add selection',
})
