local win_mgr = require 'lib.win_mgr'
local util = require 'lib.util'

local preview_win
local pre_cmd

local function run_(cmd)
    if preview_win then
        preview_win:close()
    end
    preview_win = win_mgr.openwin({})
    local buf = vim.api.nvim_win_get_buf(preview_win.win)
    vim.api.nvim_create_autocmd({'TextChanged'}, {
        buffer = buf,
        callback = function()
            vim.cmd('norm G')
        end
    })

    local keymaps_opts = { silent = true, buffer = buf }
    vim.keymap.set("n", "<Esc>", function()
        preview_win:close()
        preview_win = nil
    end, keymaps_opts)

    local chan = vim.api.nvim_open_term(buf, {})
    local job = {
        preview_win = preview_win,
        stdout = vim.loop.new_pipe(false),
        stderr = vim.loop.new_pipe(false)
    }
    local cmd_args = {}
    for i=2, #cmd do
        table.insert(cmd_args, cmd[i])
    end
    local job_opts = {
        args = cmd_args,
        stdio = {nil, job.stdout, job.stderr}
    }
    local function on_exit()
        if job.stdout then
            util.safe_close(job.stdout)
        end
        if job.stderr then
            util.safe_close(job.stderr)
        end
        if job.handle then
            util.safe_close(job.handle)
        end
    end
    local function on_output(err, data)
        if err then
            util.error(vim.inspect(err))
        end
        if data then
            vim.api.nvim_chan_send(chan, data)
        end
    end

    job.handle = vim.loop.spawn(cmd[1], job_opts, vim.schedule_wrap(on_exit))
    vim.loop.read_start(job.stdout, vim.schedule_wrap(on_output))
    vim.loop.read_start(job.stderr, vim.schedule_wrap(on_output))
    pre_cmd = cmd
end

return function()
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
