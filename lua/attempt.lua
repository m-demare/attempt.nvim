local config = require 'attempt.config'
local a = require 'plenary.async'

local M = {}

local create_dir = a.void(function (dir, cb)
  local err = a.uv.fs_mkdir(dir, 511)
  if cb then cb() end
end)

local req = function (module, fn)
  return function(...)
    local mod = require(module)
    if fn then
      return mod[fn](...)
    else
      return mod
    end
  end
end

M.setup = function(opts)
  config.setup(opts)
  create_dir(config.opts.dir)
end

M.new = req('attempt.interface', 'new')

M.new_select = req('attempt.interface', 'new_select')

M.new_input_ext = req('attempt.interface', 'new_input_ext')

M.run = req('attempt.interface', 'run')

M.open_select = req('attempt.interface', 'open_select')

M.delete = req('attempt.interface', 'delete')

M.delete_buf = req('attempt.interface', 'delete_buf')

M.delete_filtered = req('attempt.interface', 'delete_filtered')

M.rename = req('attempt.interface', 'rename')

M.rename_buf = req('attempt.interface', 'rename_buf')

return M

