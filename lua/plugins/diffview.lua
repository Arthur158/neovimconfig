local actions = require('diffview.actions')

local scroll_diff_up = actions.scroll_view(-0.5)
local scroll_diff_down = actions.scroll_view(0.5)

local function jump_diff_hunk(direction)
  return function()
    local count = vim.v.count1
    local view = require('diffview.lib').get_current_view()
    local layout = view and view.cur_layout
    local main_window = layout and layout:get_main_win()

    if not main_window or not main_window:is_valid() then
      vim.notify('No active Diffview pane to navigate', vim.log.levels.WARN)
      return
    end

    local function line_is_changed(line)
      return vim.fn.diff_hlID(line, 1) ~= 0 or vim.fn.diff_filler(line) > 0
    end

    local function find_hunk(line)
      local last_line = vim.api.nvim_buf_line_count(0)

      if direction > 0 then
        while line <= last_line and line_is_changed(line) do
          line = line + 1
        end
        while line <= last_line and not line_is_changed(line) do
          line = line + 1
        end
        return line <= last_line and line or nil
      end

      while line >= 1 and line_is_changed(line) do
        line = line - 1
      end
      while line >= 1 and not line_is_changed(line) do
        line = line - 1
      end
      if line < 1 then
        return nil
      end
      while line > 1 and line_is_changed(line - 1) do
        line = line - 1
      end
      return line
    end

    local function jump()
      local line = vim.api.nvim_win_get_cursor(0)[1]

      for _ = 1, count do
        local next_line = find_hunk(line)
        if not next_line then
          break
        end
        line = next_line
      end

      vim.api.nvim_win_set_cursor(0, { line, 0 })
      layout:sync_scroll()
    end

    if vim.api.nvim_get_current_win() ~= main_window.id then
      vim.api.nvim_win_call(main_window.id, jump)
      return
    end

    jump()
  end
end

local jump_to_next_change = jump_diff_hunk(1)
local jump_to_prev_change = jump_diff_hunk(-1)

local function hide_diff_sign_column(_, winid, ctx)
  local view = require('diffview.lib').get_current_view()
  local window = view and view.cur_layout and view.cur_layout[ctx.symbol]

  if window and window.id == winid then
    window:use_winopts({ signcolumn = 'no', foldenable = false })
  end
end

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
  old_file:use_winopts({ signcolumn = 'no' })
  new_file:use_winopts({ signcolumn = 'no' })
end

require('diffview').setup({
  hooks = {
    diff_buf_win_enter = hide_diff_sign_column,
    view_opened = arrange_review_panes,
  },
  keymaps = {
    view = {
      { 'n', 'gn', jump_to_next_change, { desc = 'Jump to the next changed hunk' } },
      { 'n', 'gp', jump_to_prev_change, { desc = 'Jump to the previous changed hunk' } },
      { 'n', '<C-u>', scroll_diff_up, { desc = 'Scroll both diff panes up' } },
      { 'n', '<C-d>', scroll_diff_down, { desc = 'Scroll both diff panes down' } },
    },
    file_panel = {
      { 'n', 'gn', jump_to_next_change, { desc = 'Jump to the next changed hunk' } },
      { 'n', 'gp', jump_to_prev_change, { desc = 'Jump to the previous changed hunk' } },
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

local function toggle_line_history()
  if require('diffview.lib').get_current_view() then
    vim.cmd('DiffviewClose')
    return
  end

  local file = vim.fn.expand('%:p')
  if file == '' then
    vim.notify('Current buffer has no file to show history for', vim.log.levels.WARN)
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd(('%dDiffviewFileHistory'):format(line))
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
    vim.cmd('DiffviewOpen')
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

vim.keymap.set('n', '<leader>gu', toggle_line_history, {
  desc = '[G]it current line history toggle',
})

vim.keymap.set('n', '<leader>gj', toggle_branch_review, {
  desc = '[G]it branch review toggle',
})

vim.keymap.set('n', '<leader>gk', close_to_reviewed_file, {
  desc = '[G]it working-tree review toggle',
})

vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<CR>', {
  desc = '[G]it diffview [Q]uit',
})

return {}
