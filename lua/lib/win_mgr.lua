local M = {}

function M.openwin(opts)
    local width = vim.o.columns
    local height = vim.o.lines
    local height_ratio = opts.height_ratio or 0.8
    local width_ratio = opts.width_ratio or 0.8
    local win_height = math.ceil(height * height_ratio)
    local win_width = math.ceil(width * width_ratio)
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)
  
    local win_opts = {
      style = "minimal",
      relative = "editor",
      width = win_width,
      height = win_height,
      row = row,
      col = col,
      border = 'single',
    }
    buf = vim.api.nvim_create_buf(false, true)
    win = vim.api.nvim_open_win(buf, true, win_opts)
    return setmetatable({win = win}, {__index = {
        close = function(self)
            local buf = vim.api.nvim_win_get_buf(self.win)
            vim.api.nvim_buf_delete(buf, {force = true})
        end
    }})
end

return M
