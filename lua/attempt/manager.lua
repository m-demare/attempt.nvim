local M = {}
local config = require 'attempt.config'
local filedata = require 'attempt.filedata'

local get_bufnr
local buf_set_opt
if vim.fn.has("nvim-0.10") == 1 then
  get_bufnr = function (bufnr)
    if bufnr and bufnr ~= 0 then return bufnr end
    return vim.fn.bufnr()
  end
  buf_set_opt = function(bufnr, opt, val)
    vim.api.nvim_set_option_value(opt, val, {
      buf = bufnr,
    })
  end
else
  get_bufnr = vim.api.nvim_buf_get_number
  buf_set_opt = vim.api.nvim_buf_set_option
end

local function standardize_opts(opts, cb)
  if not opts.filename then
    filedata.next_filename(function(name)
      opts.filename = name
      cb()
    end)
    return
  end
  cb()
end

function M.on_attempt_enter(bufnr, file_entry)
  buf_set_opt(bufnr, 'buflisted', config.opts.list_buffers)
  vim.api.nvim_buf_set_var(bufnr, 'attempt_data', file_entry)
  if config.opts.autosave then
    local augroup = vim.api.nvim_create_augroup('attempt.nvim-' .. tostring(bufnr), { clear = true })
    vim.api.nvim_create_autocmd('BufLeave', {
      buffer = bufnr,
      command = 'w',
      group = augroup
    })
  end
end

function M.open_attempt(file_entry)
  vim.cmd('edit ' .. file_entry.path)
  local bufnr = get_bufnr(0)
  M.on_attempt_enter(bufnr, file_entry)
end

function M.new(opts, cb)
  standardize_opts(opts, function()
    filedata.new_file({
      filename = opts.filename,
      ext = opts.ext,
      initial_content = opts.initial_content
    }, function(file_entry)
      vim.schedule(function()
        M.open_attempt(file_entry)
        if cb then cb(file_entry) end
      end)
    end)
  end)
end

function M.list(cb)
  filedata.get(function (data)
    vim.schedule(function()
      cb(data.file_entries)
    end)
  end)
end

function M.delete(path, cb)
  filedata.delete(path, cb)
end

function M.rename(path, new_name, cb)
  filedata.rename(path, new_name, function (new_entry)
    vim.schedule(function ()
      if not new_entry then return cb(nil) end

      local bufs = vim.api.nvim_list_bufs()
      for _, bufnr in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local buf_name = vim.api.nvim_buf_get_name(bufnr)
          if buf_name == path then
            vim.api.nvim_buf_set_name(bufnr, new_entry.path)
            vim.api.nvim_buf_set_var(bufnr, 'attempt_data', new_entry)
            -- to avoid the 'overwrite existing file' error message on write
            if vim.api.nvim_buf_get_option(bufnr, "buftype") == "" then
              vim.api.nvim_buf_call(bufnr, function()
                vim.cmd 'silent! write!'
              end)
            end
          end
        end
      end
      if cb then cb(new_entry) end
    end)
  end)
end

return M
