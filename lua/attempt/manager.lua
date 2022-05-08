local M = {}
local config = require 'attempt.config'
local filedata = require 'attempt.filedata'

local function standardize_opts(opts, cb)
  if opts.ext and opts.ext ~= '' then
    opts.ext = '.' .. opts.ext
  else
    opts.ext = ''
  end
  if not opts.filename then
    filedata.next_filename(function(name)
      opts.filename = name
      cb()
    end)
    return
  end
  cb()
end

function M.on_attempt_enter(bufnr, data)
  vim.api.nvim_buf_set_option(bufnr, 'buflisted', config.opts.list_buffers)
  vim.api.nvim_buf_set_var(bufnr, 'attempt_data', data)
  if config.opts.autosave then
    local augroup = vim.api.nvim_create_augroup('attempt.nvim-' .. tostring(bufnr), { clear = true })
    vim.api.nvim_create_autocmd('BufLeave', {
      buffer = bufnr,
      command = 'w',
      group = augroup
    })
  end
end

function M.open_attempt(data)
  vim.cmd('edit ' .. data.path)
  local bufnr = vim.api.nvim_buf_get_number(0)
  M.on_attempt_enter(bufnr, data)
end

function M.new(opts, cb)
  local ext = opts.ext or ''
  standardize_opts(opts, function()
    local full_path = config.opts.dir .. opts.filename .. opts.ext
    print(full_path, ext)
    filedata.new_file({
      filename = opts.filename,
      path = full_path,
      ext = ext,
      initial_content = opts.initial_content
    }, function(file)
      vim.schedule(function()
        M.open_attempt(file)
        if cb then cb(file) end
      end)
    end)
  end)
end

function M.list(cb)
  filedata.get(cb)
end

function M.delete(path, cb)
  filedata.delete(path, cb)
end

return M
