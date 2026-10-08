local actions = require('diffview.actions')

local scroll_diff_up = actions.scroll_view(-0.5)
local scroll_diff_down = actions.scroll_view(0.5)

require('diffview').setup({
  keymaps = {
    view = {
      { 'n', '<C-u>', scroll_diff_up, { desc = 'Scroll both diff panes up' } },
      { 'n', '<C-d>', scroll_diff_down, { desc = 'Scroll both diff panes down' } },
    },
    file_panel = {
      { 'n', 'j', actions.select_next_entry, { desc = 'Open the next file' } },
      { 'n', 'k', actions.select_prev_entry, { desc = 'Open the previous file' } },
      { 'n', '<C-u>', scroll_diff_up, { desc = 'Scroll both diff panes up' } },
      { 'n', '<C-d>', scroll_diff_down, { desc = 'Scroll both diff panes down' } },
    },
  },
})

local function toggle_file_history()
  if require('diffview.lib').get_current_view() then
    vim.cmd('DiffviewClose')
    return
  end

  local file = vim.fn.expand('%:p')
  if file == '' then
    vim.notify('Current buffer has no file to show history for', vim.log.levels.WARN)
    return
  end

  vim.cmd('DiffviewFileHistory ' .. vim.fn.fnameescape(file))
end

local function toggle_branch_review()
  if require('diffview.lib').get_current_view() then
    vim.cmd('DiffviewClose')
    return
  end

  vim.cmd('DiffviewOpen origin/trunk...HEAD --imply-local')
end

vim.keymap.set('n', '<leader>gh', toggle_file_history, {
  desc = '[G]it current file [H]istory toggle',
})

vim.keymap.set('n', '<leader>gj', toggle_branch_review, {
  desc = '[G]it branch review toggle',
})

vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<CR>', {
  desc = '[G]it diffview [Q]uit',
})

return {}
