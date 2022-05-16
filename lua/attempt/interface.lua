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
  local ok, file_entry = pcall(vim.api.nvim_buf_get_var, bufnr, 'attempt_data')
  if not ok then
    vim.notify('Not an attempt buffer', vim.log.levels.WARN, {})
    return
  end
  if not config.opts.run[file_entry.ext] then
    vim.notify('No config for running ' .. file_entry.ext .. 'files', vim.log.levels.WARN, {})
    return
  end
  print('\n') -- Prevent output from overlapping with existing msgs
  local run_cmds = config.opts.run[file_entry.ext]
  if type(run_cmds) == 'table' then
  for _, cmd in pairs(run_cmds) do
    vim.cmd(cmd)
  end
  else if type(run_cmds) == 'string' then
  vim.cmd(run_cmds)
  else
    config.opts.run[file_entry.ext](file_entry.ext, bufnr)
    end
  end
end

local function entry_to_filename(e)
  return e.filename .. (e.ext ~= '' and ('.' .. e.ext) or '')
end

function M.open_select(cb)
  manager.list(function(file_entries)
    vim.ui.select(file_entries, {
      prompt = 'Choose file to open',
      format_item = entry_to_filename
    }, function(choice)
      manager.open_attempt(choice)
      cb()
    end)
  end)
end

function M.delete(path, cb)
  manager.delete(path, cb)
end

function M.delete_buf(force, bufnr, cb)
  bufnr = bufnr or vim.api.nvim_buf_get_number(0)
  local ok, file_entry = pcall(vim.api.nvim_buf_get_var, bufnr, 'attempt_data')
  if not ok then
    vim.notify('Not an attempt buffer', vim.log.levels.WARN, {})
    return
  end
  vim.api.nvim_buf_delete(bufnr, {
    force = force
  })
  M.delete(file_entry.path, cb)
end

function M.rename(path, new_name, cb)
  manager.rename(path, new_name, cb)
end

function M.rename_buf(bufnr, cb)
  bufnr = bufnr or vim.api.nvim_buf_get_number(0)
  local ok, file_entry = pcall(vim.api.nvim_buf_get_var, bufnr, 'attempt_data')
  if not ok then
    vim.notify('Not an attempt buffer', vim.log.levels.WARN, {})
    return
  end
  vim.ui.input({
    prompt = 'New name: '
  }, function(new_name)
    M.rename(file_entry.path, new_name, cb)
  end)
end

return M
