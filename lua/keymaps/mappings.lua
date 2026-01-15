-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Mapping J to :CoqNext (step to the next Coq statement)
vim.api.nvim_set_keymap('n', ',', ':CoqNext<CR>:CoqJumpToEnd<CR>', { noremap = true, silent = true })

-- Mapping K to :CoqUndo (undo the last Coq statement)
vim.api.nvim_set_keymap('n', 'm', ':CoqUndo<CR>:CoqJumpToEnd<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '"_dd', '<leader>d', { noremap = true, silent = true })


-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- vim.api.nvim_set_keymap('i', 'kj', '<ESC>', {noremap = true, silent = true})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.WARN } })
end, { desc = 'Go to previous diagnostic warning/error' })

vim.keymap.set('n', ']d', function()
    vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.WARN } })
end, { desc = 'Go to next diagnostic warning/error' })
vim.keymap.set('n', '<leader>di', function()
    vim.diagnostic.open_float({ severity = { min = vim.diagnostic.severity.WARN } })
end, { desc = 'Open floating diagnostic message (warnings & errors only)' })

vim.keymap.set('n', '<leader>q', function()
    vim.diagnostic.setloclist({ severity = { min = vim.diagnostic.severity.WARN } })
end, { desc = 'Open diagnostics list (warnings & errors only)' })

-- keymaps for nv tree
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggled tree'})
-- vim.keymap.set('n', '<leader>e', ':NvimTreeFocus<CR>', { noremap = true, silent = true })

-- kemaps for a more confortable use of insert mode
vim.keymap.set('n', '<C-z>', 'u', { noremap = true, silent = true })
vim.keymap.set('i', '<C-z>', '<C-o>u', { noremap = true, silent = true })
vim.keymap.set('i', '<C-H>', '<C-w>', { noremap = true, silent = true })

-- vim.api.nvim_set_keymap('i', '<C-v>', '<C-r>+', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>o', '<C-V>', { noremap = true })

vim.keymap.set('n', '<A-Up>', ':m .-2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<A-Down>', ':m .+1<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<A-j>', ':m .+1<CR>', { noremap = true, silent = true })

vim.keymap.set('x', '<A-Up>', ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('x', '<A-k>', ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('x', '<A-Down>', ":move '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('x', '<A-j>', ":move '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Map Tab to switch to next buffer

-- vim.api.nvim_set_keymap('n', '<Space>x', ':if &modified | w | bd | else | bd | endif<CR>', { noremap = true, silent = true })

-- Move to previous/next
vim.keymap.set('n', '<S-Tab>', '<Cmd>BufferPrevious<CR>')
vim.keymap.set('n', '<Tab>', '<Cmd>BufferNext<CR>')
-- Re-order to previous/next
vim.keymap.set('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>')
vim.keymap.set('n', '<A->>', '<Cmd>BufferMoveNext<CR>')
-- Goto buffer in position...
vim.keymap.set('n', '<A-1>', '<Cmd>BufferGoto 1<CR>')
vim.keymap.set('n', '<A-2>', '<Cmd>BufferGoto 2<CR>')
vim.keymap.set('n', '<A-3>', '<Cmd>BufferGoto 3<CR>')
vim.keymap.set('n', '<A-4>', '<Cmd>BufferGoto 4<CR>')
vim.keymap.set('n', '<A-5>', '<Cmd>BufferGoto 5<CR>')
vim.keymap.set('n', '<A-6>', '<Cmd>BufferGoto 6<CR>')
vim.keymap.set('n', '<A-7>', '<Cmd>BufferGoto 7<CR>')
vim.keymap.set('n', '<A-8>', '<Cmd>BufferGoto 8<CR>')
vim.keymap.set('n', '<A-9>', '<Cmd>BufferGoto 9<CR>')
vim.keymap.set('n', '<A-0>', '<Cmd>BufferLast<CR>')
-- Pin/unpin buffer
vim.keymap.set('n', '<A-p>', '<Cmd>BufferPin<CR>')
-- Close buffer
vim.keymap.set('n', '<C-w>', '<Cmd>BufferClose<CR>')
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft

--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
vim.keymap.set('n', '<C-p>', '<Cmd>BufferPick<CR>')
-- Sort automatically by...
vim.keymap.set('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>')
-- vim.keymap.set('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>')
-- vim.keymap.set('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>')
-- vim.keymap.set('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>')

vim.api.nvim_set_keymap('x', '>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<', '<gv', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<C-a>', '<Esc>ggVG', {noremap = true, silent = true})

-- Define the function within the Lua script (locally)
local toggle_vsplit = function()
    local win_count = vim.fn.winnr('$')
    if win_count == 1 then
        vim.cmd('vsplit')
    elseif win_count >= 2 then
        vim.cmd('close')
    end
end

-- Store the function in the global table `vim` to reference it in the keymap command
_G.toggle_vsplit = toggle_vsplit

function SaveAndQuit()
    -- Check if in terminal mode and exit if true
    if vim.bo.buftype == 'terminal' then
        vim.api.nvim_input('<C-\\><C-n>')
    end
    -- Kill all floaterms, save all buffers, and quit
    vim.cmd('FloatermKill')
    vim.cmd('wa')
    vim.cmd('qa!')
end

vim.api.nvim_set_keymap('n', '<C-r>', ':lua SaveAndQuit()<CR>', {noremap = true, silent = true})

-- set the keymap to call the global function
vim.api.nvim_set_keymap('n', '<c-a>', ':lua toggle_vsplit()<cr>', { noremap = true, silent = true })

-- vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', {noremap = true, silent = true})
-- vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', {noremap = true, silent = true})

-- vim.api.nvim_set_keymap('n', '<leader>h', ':wqa<CR>', {noremap = true, silent = true})

local diagnostics_active = true

function ToggleDiagnostics()
    if diagnostics_active then
        vim.diagnostic.show()
    else
        vim.diagnostic.hide()
    end
    diagnostics_active = not diagnostics_active
end

vim.api.nvim_set_keymap('n', '<C-y>', '<cmd>lua ToggleDiagnostics()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>p', "\"_dP", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>o', ":echo @%<CR>", { noremap = true, silent = true })

function ToggleWrap()
    if vim.wo.wrap then
        vim.wo.wrap = false
    else
        vim.wo.wrap = true
    end
end

vim.api.nvim_set_keymap('n', '<leader>v', ':lua ToggleWrap()<CR>', {noremap = true, silent = true})

