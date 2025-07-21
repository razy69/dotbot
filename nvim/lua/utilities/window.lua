-- WIP: utilities to resize window in a natural way

local fake_layout = { "col",
  {
    { "leaf", 1000 },
    {
      "row",
      {
        { "leaf", 1024 },
        { "leaf", 1026 },
        { "leaf", 1028 },
        { "leaf", 1030 },
        {
          "col",
          {
            { "leaf", 1032 },
            { "leaf", 1034 },
          },
        },
      },
    },
    {
      "row",
      {
        { "leaf", 1006 },
        {
          "col",
          {
            { "leaf", 1020 },
            { "leaf", 1022 },
          },
        },
      },
    },
    {
      "row",
      {
        { "leaf", 1010 },
        { "leaf", 1014 },
        { "leaf", 1016 },
        { "leaf", 1018 },
      },
    },
  },
}

local second_fake_layout = { "row",
  {
    { "leaf", 1003 },
    {
      "col",
      {
        { "leaf", 1046 },
        {
          "row",
          {
            { "leaf", 1053 },
            {
              "col",
              {
                { "leaf", 1067 },
                { "leaf", 1069 },
              },
            },
          },
        },
      },
    },
  }

}

local M = {
  parent_node = nil,
  parent_node_type = nil,
  parent_node_index = nil,
  parent_node_layout = nil,
}

function M.win_screen_pos(win_id)
  return vim.fn.win_screenpos(win_id)
end

function M.is_win_top_left(win_id)
  local screen_pos = M.win_screen_pos(win_id)
  return screen_pos[1] == 1 and screen_pos[2] == 1
end

function M.is_win_top(win_id)
  return M.win_screen_pos(win_id)[1] == 1
end

function M.is_win_left_most(win_id)
  return M.win_screen_pos(win_id)[2] == 1
end

function M.get_layout()
  return vim.fn.winlayout()
end

function M.get_win_id()
  return vim.api.nvim_get_current_win()
end

function M.get_win_width(win_id)
  return vim.api.nvim_win_get_width(win_id)
end

function M.get_win_height(win_id)
  return vim.api.nvim_win_get_height(win_id)
end

function M.set_win_width(win_id, width)
  vim.api.nvim_win_set_width(win_id, width)
end

function M.set_win_height(win_id, height)
  vim.api.nvim_win_set_height(win_id, height)
end

function M.get_first_next_win_id_from_layout(layout)
  for _, element in ipairs(layout) do
    if element[1] == "leaf" and type(element[2] == "number") then
      return element[2]
    end
  end
end

function M.find_node(win_id, layout)
  for i, element in ipairs(layout) do

    -- { "leaf", 1000 }
    if element[1] == "leaf" and element[2] == win_id then
      return i, layout

    -- { "row", {...} } || { "col", {...} }
    elseif element[1] == "row" or element[1] == "col" then
      local j, _layout = M.find_node(win_id, element[2])

      if j ~= nil and _layout ~= nil then
        M.parent_node = element
        M.parent_node_type = element[1]
        M.parent_node_index = i
        M.parent_node_layout = layout
        return j, _layout
      end
    end

  end

  return nil, nil
end

function M.get_win_id_from_layout(win_pos, layout)
  for _, win in ipairs(layout[win_pos]) do
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

function M.is_win_last(win_pos, layout)
  return #layout == win_pos
end

function M.resize_left(resize_speed)
  local layout = M.get_layout()

  if layout[1] == "leaf" then
    return
  end

  local win_id = M.get_win_id()
  local win_width = M.get_win_width(win_id)
  local win_pos, win_layout = M.find_node(win_id, layout[2])

  if M.is_win_top_left(win_id) or win_pos == nil or win_layout == nil then
    M.set_win_width(win_id, win_width - resize_speed)
    return
  end

  vim.print(win_id, win_pos, win_layout, M.parent_node, M.parent_node_type, M.parent_node_index, M.parent_node_layout, layout[2])

  if M.is_win_first(win_pos) or #win_layout == 1 then
    if M.parent_node ~= nil and M.parent_node_type == "row" then
      local prev_win_id = M.get_win_id_from_layout(M.parent_node_index - 1, M.parent_node_layout)
      local prev_win_width = M.get_win_width(prev_win_id)
      M.set_win_width(prev_win_id, prev_win_width - resize_speed)
    else
      M.set_win_width(win_id, win_width + resize_speed)
    end
  else
    local prev_win_id = M.get_win_id_from_layout(win_pos - 1, win_layout)
    local prev_win_width = M.get_win_width(prev_win_id)
    M.set_win_width(prev_win_id, prev_win_width - resize_speed)
  end

end

function M.resize_right(resize_speed)
  local layout = M.get_layout()

  if layout[1] == "leaf" then
    return
  end

  local win_id = M.get_win_id()
  local win_width = M.get_win_width(win_id)
  local win_pos, win_layout = M.find_node(win_id, layout[2])

  if M.is_win_top_left(win_id) or win_pos == nil or win_layout == nil then
    M.set_win_width(win_id, win_width + resize_speed)
    return
  end

  -- vim.print(win_id, win_pos, win_layout, M.parent_node, M.parent_node_type, M.parent_node_index, M.parent_node_layout, layout[2])

  if M.is_win_first(win_pos) or #win_layout == 1 then
    M.set_win_width(win_id, win_width + resize_speed)
    vim.notify('first')
  elseif M.is_win_last(win_pos, win_layout) then
    vim.notify('last')
    local prev_win_id = M.get_win_id_from_layout(win_pos - 1, win_layout)
    local prev_win_width = M.get_win_width(prev_win_id)
    M.set_win_width(prev_win_id, prev_win_width + resize_speed)
  else
    local next_win_pos = win_pos + 1
    local next_win_id = M.get_win_id_from_layout(next_win_pos, win_layout)
    vim.print('middle', next_win_pos, next_win_id, #win_layout)
    if next_win_pos == #win_layout then
      M.set_win_width(win_id, win_width + resize_speed)
    else
      local next_win_width = M.get_win_width(next_win_id)
      M.set_win_width(next_win_id, next_win_width - resize_speed)
    end
  end

end

function M.resize_up(resize_speed)
end

function M.resize_down(resize_speed)
end

return M
