local M = {}

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "xh" })
end

function M.safe_close(h)
  if not h:is_closing() then
    h:close()
  end
end

return M
