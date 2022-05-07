local M = {}
local config = require 'attempt.config'
local manager = require 'attempt.manager'

M.new = manager.new

function M.new_select(cb)
  vim.ui.select(config.opts.ext_options, {
    prompt = 'Choose file extension',
    format_item = function(item)
      return config.opts.format_opts[item] or item
    end
  }, function(choice)
    M.new({ ext = choice }, cb)
  end)
end

function M.new_input_ext(cb)
  vim.ui.input({
    prompt = 'File extension: ',
  }, function(choice)
    M.new({ ext = choice }, cb)
  end)
end

function M.run(bufnr)
  bufnr = bufnr or vim.api.nvim_buf_get_number(0)
  local ok, data = pcall(vim.api.nvim_buf_get_var, bufnr, 'attempt_data')
  if not ok then
    vim.notify('Not an attempt buffer', vim.log.levels.WARN, {})
    return
  end
  if not config.opts.run[data.ext] then
    vim.notify('No config for running ' .. data.ext .. 'files', vim.log.levels.WARN, {})
    return
  end
  if type(config.opts.run[data.ext]) == 'string' then
    vim.cmd(config.opts.run[data.ext])
  else
    config.opts.run[data.ext](bufnr)
  end
end

return M

