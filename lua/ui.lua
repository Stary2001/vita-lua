-- ui
ui = {}
function ui.choose(options, title, selected, hook, titlecolor, selectedoptcolor, optioncolor, font_custom)
  local font_to_use = font_custom or font or vita2d.load_font()
  local selectedoptcolor = selectedcolor or colors.red
  local optioncolor = optioncolor or colors.white
  local titlecolor = titlecolor or colors.blue

  local hooks = hooks or {}

  local old_pad = input.peek()

  local selected = selected or 1
  local num = 18
  if title then
    num = 17
  end
  
  while true do
    local pad = input.peek()
    vita2d.start_drawing()
    vita2d.clear_screen()

    local p = 0

    local min = (selected <= num and 1 or selected - num + 1)
    local max = math.min(#options, (selected <= num and num or selected))

    if title then
      font_to_use:draw_text(0, 0, titlecolor, 30, title)
      p = 1
    end
    for i=min, max do
      font_to_use:draw_text(0, p * 30, i == selected and selectedoptcolor or optioncolor, 30, options[i])
      p = p + 1
    end

    vita2d.end_drawing()
    vita2d.swap_buffers()

    if hook then
      abort, res = hook(options[selected], old_pad, pad)
      if abort then
        return res, abort
      end
    end

    if old_pad:up() and not pad:up() and selected > 1 then
      selected = selected - 1
    elseif old_pad:down() and not pad:down() and selected < #options then
      selected = selected + 1
    elseif old_pad:cross() and not pad:cross() then
      return options[selected], false
    elseif old_pad:circle() and not pad:circle() then
      return nil
    end

    old_pad = pad
  end
end

function ui.view_image(tex, font_custom)
  local font_to_use = font_custom or font or vita2d.load_font()

  local old_pad = input.peek()
  local white = false

  local ratio = math.min(960 / tex:width(), 544 / tex:height())

  while true do
    local pad = input.peek()
    vita2d.start_drawing()
    vita2d.clear_screen()
    tex:draw_scale((960 - tex:width()*ratio)/2 , (540 - tex:height()*ratio)/2, ratio, ratio)
    font_to_use:draw_text(0, 0, white and colors.black or colors.white, 30, tostring(tex:width()) .. "x" .. tostring(tex:height()))
    vita2d.end_drawing()
    vita2d.swap_buffers()

    if old_pad:circle() and not pad:circle() then break end
    if old_pad:cross() and not pad:cross() then break end

    if old_pad:triangle() and not pad:triangle() then
      white = not white
      vita2d.set_clear_color(white and colors.white or colors.black)
    end

    old_pad = pad
  end
  vita2d.set_clear_color(colors.black)
end

function ui.choose_file(startdir, title, hook)
  local startdir = string.gsub(startdir or "/", "/$", "")
  local path = {""}
  if startdir then
    local leftover = string.gsub(startdir, "..-/", function(e)
      local t = string.gsub(e, "^/(.+)/$", "%1")
      table.insert(path, t)
      return ""
    end)
    if leftover then
      table.insert(path, leftover)
    end
  end
  while true do
    local t = physfs.list(table.concat(path, "/") .. "/")
    if not string.find(table.concat(path, "/") .. "/", "^/$") then
      table.insert(t, 1, "..")
    end
    res, abort = ui.choose(t, title or table.concat(path, "/").."/", nil, function(res, old_pad, pad)
      if hook then
        return hook(res, old_pad, pad, table.concat(path, "/") .. "/" .. res)
      end
    end)
    if abort then
      return res
    end
    if res == ".." or res == nil then
      if #path > 1 then
        table.remove(path)
      end
    else
      if physfs.is_dir(table.concat(path, "/") .. "/" .. res) then
        table.insert(path, res)
      else
        return (table.concat(path, "/") .. "/" .. res), table.concat(path, "/")
      end
    end
  end
end
