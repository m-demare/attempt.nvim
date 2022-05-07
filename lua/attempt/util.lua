local M = {}

function M.find(tbl, fn)
  for i, v in ipairs(tbl) do
    if fn(v, i) then return v, i end
  end
  return nil, nil
end

return M

