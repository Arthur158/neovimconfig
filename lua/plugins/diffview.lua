local actions = require('diffview.actions')

local scroll_diff_up = actions.scroll_view(-0.5)
local scroll_diff_down = actions.scroll_view(0.5)

local function arrange_review_panes(view)
  local layout = view.cur_layout
  local old_file = layout and layout.a
  local new_file = layout and layout.b

  if not old_file or not new_file or not old_file:is_valid() or not new_file:is_valid() then
    return
  end

  -- Diffview's two-way layout is old | new. Move old to the far right so the
  -- file panel remains leftmost, followed by the larger new pane and old pane.
  vim.api.nvim_win_call(old_file.id, function()
    vim.cmd('wincmd L')
  end)

  local diff_width = vim.api.nvim_win_get_width(old_file.id)
    + vim.api.nvim_win_get_width(new_file.id)
  vim.api.nvim_win_set_width(old_file.id, math.max(1, math.floor(diff_width * 2 / 5)))
end

require('diffview').setup({
  hooks = {
    diff_buf_win_enter = function(_, winid)
      vim.wo[winid].signcolumn = 'no'
    end,
    view_opened = arrange_review_panes,
  },
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

local function close_to_reviewed_file()
  local view = require('diffview.lib').get_current_view()
  if not view then
    vim.notify('No Diffview is open', vim.log.levels.WARN)
    return
  end

  if not view:infer_cur_file() then
    vim.notify('No file is selected in Diffview', vim.log.levels.WARN)
    return
  end

  actions.goto_file_edit()
  view:close()
end

vim.keymap.set('n', '<leader>gh', toggle_file_history, {
  desc = '[G]it current file [H]istory toggle',
})

vim.keymap.set('n', '<leader>gj', toggle_branch_review, {
  desc = '[G]it branch review toggle',
})

vim.keymap.set('n', '<leader>gk', close_to_reviewed_file, {
  desc = '[G]it close review at current file',
})

vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<CR>', {
  desc = '[G]it diffview [Q]uit',
})

return {}
