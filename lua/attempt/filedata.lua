local M = {}
local config = require 'attempt.config'
local util = require 'attempt.util'
local a = require 'plenary.async'

local data_file_path = config.opts.dir .. "plug.data"
local filemode = 438 -- = 0o666

M.get = a.void(function (cb)
  local err, fd = a.uv.fs_open(data_file_path, 'r', filemode)
  if err then
    return cb {
      internal = { version = 1, num_files = 0 },
      file_entries = {}
    }
  end
  local err, stat = a.uv.fs_fstat(fd)
  assert(not err, err)
  local err, data = a.uv.fs_read(fd, stat.size, 0)
  assert(not err, err)

  vim.schedule(function()
    cb = a.void(cb)
    cb(vim.fn.luaeval(data))
  end)
end)

M.save = a.void(function (data, cb)
    local strdata = vim.inspect(data)
    local err, fd = a.uv.fs_open(data_file_path, "w", filemode)
    assert(not err, err)
    local err = a.uv.fs_write(fd, strdata, 0)
    assert(not err, err)
    if cb then cb() end
end)

M.new_file = a.void(function (opts, cb)
  M.get(function(data)
    local old_entry = util.find(data.file_entries, function (f)
      return f.path == opts.path
    end)
    if old_entry then cb(old_entry); return end

    local new_entry = {
      path = opts.path,
      filename = opts.filename,
      ext = opts.ext,
      creation_date = os.time()
    }
    table.insert(data.file_entries, new_entry)

    -- Save new file
    local err, fd = a.uv.fs_open(opts.path, 'w', filemode)
    assert(not err, err)
    local content = opts.initial_content or config.opts.initial_content[opts.ext] or ''
    if type(content) == 'function' then content = content(opts.ext) end
    local err = a.uv.fs_write(fd, content, 0)
    assert(not err, err)

    data.internal.num_files = data.internal.num_files + 1
    M.save(data, function()
      cb(new_entry)
    end)
  end)
end)

function M.next_filename(cb)
  M.get(function (data)
    cb('scratch-' .. tostring(data.internal.num_files))
  end)
end

M.delete = a.void(function (path, cb)
  M.get(function (data)
    local _, i = util.find(data.file_entries, function (f)
      return f.path == path
    end)
    if not i then cb(false); return end
    table.remove(data.file_entries, i)

    -- Delete file
    local err = a.uv.fs_unlink(path)
    assert(not err, err)

    M.save(data, function ()
      if cb then cb(true) end
    end)
  end)
end)

return M

