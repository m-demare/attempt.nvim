local function entry_to_ext(e)
  return (e.ext and e.ext ~= '' and ('.' .. e.ext) or '')
end

return {
  picker = function (opts)
    local ok, snacks= pcall(require, "snacks")
    if not ok then error "snacks not available" end

    local filedata = require "attempt.filedata"
    filedata.get(function (data)
      local file_entries = data.file_entries
      vim.schedule(function ()
        local items = vim.tbl_map(function (entry)
          return {
            file = entry.path,
            text = entry.filename .. entry_to_ext(entry),
            entry = entry,
          }
        end, file_entries)

        local picker = vim.tbl_deep_extend("force", {}, {
          title = "Scratch files",
          items = items,
          format = function (item)
            if not item then return {} end
            return {
              { item.entry.filename, "SnacksPickerFile" },
              { entry_to_ext(item.entry), "SnacksPickerAuEvent" },
            }
          end,
          confirm = function (picker, item, action)
            picker:close()

            local cmd = snacks.picker.actions[action.name]
            if type(cmd) == "function" then
              cmd(picker, item, action)
            else
              vim.cmd(cmd.cmd .. " " .. item.file)
            end

            local open_file_cmds = { "confirm", "edit_vsplit", "vsplit", "edit_split", "split", "edit_tab", "tab" }
            if not vim.tbl_contains(open_file_cmds, action.name) then
              return
            end

            -- vim.schedule necessary because `cmd` function sometimes does vim.schedule too
            vim.schedule(function()
              local manager = require 'attempt.manager'
              manager.on_attempt_enter(vim.fn.bufnr(), item.entry)
            end)
          end,
        }, opts or {})

        return snacks.picker(picker)
      end)
    end)
  end
}
