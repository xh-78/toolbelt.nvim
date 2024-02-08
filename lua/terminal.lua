local terminal
local terminal_show = false

function toggle_terminal()
    if terminal_show then
        vim.cmd 'wincmd p'
        vim.api.nvim_win_hide(terminal.win)
        terminal_show = false
    else
        local cols = vim.o.columns
        local rows = vim.o.lines
        local width = math.ceil(cols * 0.8) - 1
        local height = math.ceil(rows * 0.7) - 1
        local pos_row = math.ceil((rows - height) / 2)
        local pos_col = math.ceil((cols - width) / 2)
        if terminal == nil then
            local buf = vim.api.nvim_create_buf(false, false)
            local win = vim.api.nvim_open_win(buf, true, {relative='editor', row=pos_row, col=pos_col, width=width, height=height, border='single'})
            vim.fn.termopen('bash', {
                detach = false;
            })
            terminal = {
                buf = buf,
                win = win
            }
        else
            local win = vim.api.nvim_open_win(terminal.buf, true, {relative='editor', row=pos_row, col=pos_col, width=width, height=height, border='single'})
            terminal.win = win
        end
        terminal.pre_win = vim.api.nvim_get_current_win()
        terminal_show = true
        vim.cmd 'startinsert'
    end
end

return function()
    vim.api.nvim_set_keymap('', '<leader>tt', '<cmd>lua toggle_terminal()<CR>', {noremap = true})
    vim.api.nvim_set_keymap('t', '<leader>tt', '<cmd>lua toggle_terminal()<CR>', {noremap = true})
end
