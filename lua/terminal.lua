local terminal
local terminal_show = false
local pre_cmd

local function run_(cmd)
    if terminal_show then
        vim.api.nvim_set_current_win(terminal.win)
        vim.cmd 'startinsert'
    else
        toggle_terminal()
    end
    local cmd_str = table.concat(cmd, ' ') .. ' <CR>'
    local keys = vim.api.nvim_replace_termcodes(cmd_str, true, true, true)
    vim.api.nvim_feedkeys(keys, 'a', true)
    pre_cmd = cmd
end

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
    vim.api.nvim_create_user_command('Run', function(opts)
        run_(opts.fargs)
    end, { nargs = '*', complete = 'shellcmd' })
    vim.api.nvim_create_user_command('ReRun', function(opts)
        if pre_cmd then
            run_(pre_cmd)
        end
    end, { nargs = 0})
    vim.api.nvim_set_keymap('', '<leader>rr', ':ReRun<CR>', {noremap = true})
end
