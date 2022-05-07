local M = {}

local unix = vim.fn.has 'unix' == 1
local path_separator = unix and '/' or '\\'

local defaults = {
  dir = (unix and '/tmp/' or vim.fn.expand '$TEMP\\') .. 'attempt.nvim' .. path_separator,
  autosave = false,
  list_buffers = false,
  initial_content = {},
  ext_options = { 'lua', 'js', 'py', 'cpp', 'c', '' },
  format_opts = { [''] = '[None]' }
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  -- TODO assert dir ends with path_separator
end

return M


