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

local function on_created(bufnr, opts)
  vim.api.nvim_buf_set_option(bufnr, 'buflisted', config.opts.list_buffers)
  vim.api.nvim_buf_set_var(bufnr, 'is_attempt', true)
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
        vim.cmd('edit ' .. full_path)
        local bufnr = vim.api.nvim_buf_get_number(0)
        on_created(bufnr)
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
