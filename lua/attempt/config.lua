local M = {}

local unix = vim.fn.has 'unix' == 1
local path_separator = unix and '/' or '\\'

local defaults = {
  dir = (unix and '/tmp/' or vim.fn.expand '$TEMP\\') .. 'attempt.nvim' .. path_separator,
  autosave = false,
  list_buffers = false,
  initial_content = {},
  ext_options = { 'lua', 'js', 'py', 'cpp', 'c', '' },
  format_opts = { [''] = '[None]' },
  run = {
    py = 'w !python',
    js = 'w !node',
    lua = 'w | luafile %'
  }
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  if not string.find(M.opts.dir, path_separator .. '$') then
    M.opts.dir = M.opts.dir .. path_separator
  end
end

return M


