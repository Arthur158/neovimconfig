-- copilot.lua
-- Configuration for GitHub Copilot

-- Assuming you are using the 'zbirenbaum/copilot.lua' plugin
-- and not the 'github/copilot.vim' plugin

require('copilot').setup({
  -- panel = {
  --   enabled = true,
  --   auto_refresh = false,
  --   keymap = {
  --     jump_prev = "[[",
  --     jump_next = "]]",
  --     accept = "<CR>",
  --     refresh = "gr",
  --     open = "<A-CR>"
  --   },
  --   layout = {
  --     position = "bottom",
  --     ratio = 0.4
  --   },
  -- },
  suggestion = {

    enabled = true,
    auto_trigger = false,
    debounce = 75,
    keymap = {
      accept = "<M-l>",
      accept_word = false,
      accept_line = false,
      next = "<A-[>",
      -- prev = "<A-[>",
      dismiss = "<A-]>"
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false
  },
  copilot_node_command = 'node', -- Node.js version must be > 18.x
  server_opts_overrides = {}
})

-- Additional configuration for Copilot status in the statusline (lualine)
-- local Util = require("lazyvim.util")
-- local colors = {
--   [""] = Util.ui.fg("Special"),
--   ["Normal"] = Util.ui.fg("Special"),
--   ["Warning"] = Util.ui.fg("DiagnosticError"),
--   ["InProgress"] = Util.ui.fg("DiagnosticWarn"),
-- }

-- -- Assuming you're using lualine and want to integrate Copilot status
-- require('lualine').setup({
--   sections = {
--     -- ... your existing lualine configuration
--     lualine_x = {
--       { 'copilot#status', color = { fg = colors.Normal, gui = 'bold' } },
--       -- ... other lualine_x components
--     },
--   },
--   -- ... other lualine setup options
-- })
--
-- Return from this file so it can be required successfully
return {}
