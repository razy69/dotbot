local M = {}

function M.get_position(win_id, layout)
  for i, element in ipairs(layout) do
    if element[1] == "leaf" then
      if element[2] == win_id then
        return i, layout
      end
    elseif type(element[2]) == "table" then
      local index, sub_layout = M.get_position(win_id, element[2])
      if index ~= 0 and element[1] == "row" then
        return index, sub_layout
      elseif index ~= 0 and element[1] == "col" then
        return i, layout
      end
    end
  end
  return 0, nil
end

function M.get_first_available_win_id(win_layout, win_pos)
  for _, win in ipairs(win_layout[win_pos]) do
    if type(win) == "number" then
      return win
    end

    if type(win) == "table" then
      return win[1][2]
    end
  end
end

function M.is_win_first(win_pos)
  return win_pos == 1
end

function M.is_win_last(win_layout, win_pos)
  return #win_layout == win_pos
end

function M.resize_left(resize_speed)
  local current_win_id = vim.api.nvim_get_current_win()
  local current_win_width = vim.api.nvim_win_get_width(current_win_id)
  local layout = vim.fn.winlayout()
  local current_win_pos, win_layout = M.get_position(current_win_id, layout[2])

  -- only 1 window or the left most
  if M.is_win_first(current_win_pos) then
    vim.api.nvim_win_set_width(current_win_id, current_win_width - resize_speed)
    return
  end

  if M.is_win_last(win_layout, current_win_pos) then
    vim.api.nvim_win_set_width(current_win_id, current_win_width + resize_speed)
  else
    local before_win_id = M.get_first_available_win_id(win_layout, current_win_pos - 1)
    local before_win_width = vim.api.nvim_win_get_width(before_win_id)
    vim.api.nvim_win_set_width(before_win_id, before_win_width - resize_speed)
  end
end

function M.resize_right(resize_speed)
  local current_win_id = vim.api.nvim_get_current_win()
  local current_win_width = vim.api.nvim_win_get_width(current_win_id)
  local layout = vim.fn.winlayout()
  local current_win_pos, win_layout = M.get_position(current_win_id, layout[2])

  -- only 1 window or the left most
  if M.is_win_first(current_win_pos) then
    vim.api.nvim_win_set_width(current_win_id, current_win_width + resize_speed)
    return
  end

  if M.is_win_last(win_layout, current_win_pos) then
    vim.api.nvim_win_set_width(current_win_id, current_win_width - resize_speed)
  else
    local before_win_id = M.get_first_available_win_id(win_layout, current_win_pos + 1)
    local before_win_width = vim.api.nvim_win_get_width(before_win_id)
    vim.api.nvim_win_set_width(before_win_id, before_win_width - resize_speed)
  end
end

function M.resize_up(resize_speed)
  local current_win_id = vim.api.nvim_get_current_win()
  local current_win_height = vim.api.nvim_win_get_height(current_win_id)
  local win_screenpos = vim.fn.win_screenpos(current_win_id)

  if win_screenpos[1] == 1 then
    vim.notify("top", "DEBUG")
    vim.api.nvim_win_set_height(current_win_id, current_win_height - resize_speed)
    return
  end

  local layout = vim.fn.winlayout()
  local current_win_pos, win_layout = M.get_position(current_win_id, layout[2])

  vim.print(
    "global layout",
    layout[2],
    "up win_layout",
    win_layout,
    "win_id",
    current_win_id
  )

  if M.is_win_last(win_layout, current_win_pos) then
    vim.api.nvim_win_set_height(current_win_id, current_win_height + resize_speed)
  else
    local before_win_id = M.get_first_available_win_id(win_layout, current_win_pos - 1)
    local before_win_height = vim.api.nvim_win_get_height(before_win_id)
    vim.api.nvim_win_set_height(before_win_id, before_win_height - resize_speed)
  end
end

function M.resize_down(resize_speed)
  local current_win_id = vim.api.nvim_get_current_win()
  local current_win_height = vim.api.nvim_win_get_height(current_win_id)
  local win_screenpos = vim.fn.win_screenpos(current_win_id)

  if win_screenpos[1] == 1 then
    vim.notify("top", "DEBUG")
    vim.api.nvim_win_set_height(current_win_id, current_win_height + resize_speed)
    return
  end

  -- vim.print("win_layout", win_layout, "win_id", current_win_id)
  -- if M.is_win_first(current_win_pos) then
  --   vim.notify("top", "DEBUG")
  --   vim.api.nvim_win_set_height(current_win_id, current_win_height - resize_speed)
  --   return
  -- end

  local layout = vim.fn.winlayout()
  local current_win_pos, win_layout = M.get_position(current_win_id, layout[2])

  if M.is_win_last(win_layout, current_win_pos) then
    vim.api.nvim_win_set_height(current_win_id, current_win_height - resize_speed)
  else
    local before_win_id = M.get_first_available_win_id(win_layout, current_win_pos + 1)
    local before_win_height = vim.api.nvim_win_get_height(before_win_id)
    vim.api.nvim_win_set_height(before_win_id, before_win_height - resize_speed)
  end
end

return M
