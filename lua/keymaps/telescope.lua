--key mappings for telescope

-- See `:help telescope.builtin`
local telescope_utils = require('config.telescope_utils')

vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>/', function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
	  winblend = 10,
	  previewer = false,
	})
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', telescope_utils.picker('git_files'), { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>f', telescope_utils.find_files_by_extension, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sf', telescope_utils.picker('find_files'), { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>se', telescope_utils.find_files_by_extension, { desc = '[S]earch by file [E]xtension' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', telescope_utils.picker('grep_string'), { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>g', telescope_utils.picker('live_grep'), { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sg', telescope_utils.picker('live_grep'), { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
--- Keybinding example
-- vim.api.nvim_set_keymap('n', '<leader>sr', ":Telescope frecency<CR>", {noremap = true})

-- -- Startup command example
-- vim.api.nvim_create_autocmd("VimEnter", {
--   pattern = "*",
--   callback = function()
--     if #vim.fn.argv() == 1 and vim.fn.isdirectory(vim.fn.argv()[1]) == 1 then
--       vim.defer_fn(function() vim.cmd("Telescope frecency") end, 10) -- delay to allow time for nvim to startup
--     end
--   end
-- })- vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    local arg = vim.fn.argv(0)
    if vim.fn.isdirectory(arg) == 1 then
      telescope_utils.picker('find_files')()
    end
  end
})
