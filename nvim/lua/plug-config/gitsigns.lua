local utils = require('utils')
local gitsigns = require('gitsigns')

local function refresh_fugitive()
    local current_window = vim.api.nvim_get_current_win()
    vim.cmd [[ windo if &ft == 'fugitive' | :edit | end ]]
    vim.api.nvim_set_current_win(current_window)
end

-- NOTE(vir): updates fugitive windows
require('gitsigns').setup {
    numhl = false,
    linehl = false,
    preview_config = {border = 'rounded'},
    on_attach = function(buffer_nr)
        utils.map('n', ']c', function()
            if vim.wo.diff then return ']c' end

            vim.schedule(gitsigns.next_hunk)
            return '<Ignore>'
        end, {expr = true, silent = true}, buffer_nr)

        utils.map('n', '[c', function()
            if vim.wo.diff then return '[c' end

            vim.schedule(gitsigns.prev_hunk)
            return '<Ignore>'
        end, {expr = true, silent = true}, buffer_nr)

        utils.map({'n', 'v'}, '<leader>gs', function()
            vim.cmd('Gitsigns stage_hunk')
            vim.schedule(refresh_fugitive)
        end, {silent = true}, buffer_nr)

        utils.map('n', '<leader>gu', function()
            gitsigns.undo_stage_hunk()
            vim.schedule(refresh_fugitive)
        end, {silent = true}, buffer_nr)

        utils.map({'n', 'v'}, '<leader>gr', '<cmd>Gitsigns reset_hunk<cr>',
                  {silent = true}, buffer_nr)
        utils.map('n', '<leader>gp', gitsigns.preview_hunk, {silent = true},
                  buffer_nr)
        utils.map('n', '<leader>gt', gitsigns.toggle_deleted, {silent = true},
                  buffer_nr)

        utils.map({'o', 'x'}, 'ig', gitsigns.select_hunk, {silent = true},
                  buffer_nr)
        utils.map({'o', 'x'}, 'ag', gitsigns.select_hunk, {silent = true},
                  buffer_nr)
    end
}
