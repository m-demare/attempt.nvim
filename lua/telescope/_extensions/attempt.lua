local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local action_state = require 'telescope.actions.state'
local action_set = require 'telescope.actions.set'

local function entry_to_filename(e)
  return e.value.filename .. (e.value.ext and e.value.ext ~= '' and ('.' .. e.value.ext) or '')
end

local function scratch_picker(opts)
  local filedata = require 'attempt.filedata'
  filedata.get(function (data)
    local file_entries = data.file_entries
    vim.schedule(function ()
      opts = opts or {}
      pickers.new(opts, {
        prompt_title = "Scratch files",
        finder = finders.new_table {
          results = file_entries,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry_to_filename,
              ordinal = entry_to_filename({ value = entry }),
              path = entry.path
            }
          end
        },
        sorter = conf.generic_sorter(opts),
        previewer = conf.file_previewer(opts),
        attach_mappings = function(prompt_bufnr, map)
          action_set.select:replace(function (prompt_bufnr, type)
            action_set.edit(prompt_bufnr, action_state.select_key_to_edit_key(type))
            local selection = action_state.get_selected_entry()
            if selection then
              local manager = require 'attempt.manager'
              manager.on_attempt_enter(vim.api.nvim_buf_get_number(0), selection.value)
            end
          end)
          return true
        end,
      }):find()
    end)
  end)
end


return require('telescope').register_extension {
  exports = {
    attempt = scratch_picker
  }
}
