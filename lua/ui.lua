-- ui
ui = {}
function ui.choose(options, title, selected, hook, titlecolor, selectedoptcolor, optioncolor, font_custom)
  print("ui.choose")
  if not options then
    error("ui.choose: no options given")
  end
  local font_to_use = font_custom or font or vita2d.load_font()
  local selectedoptcolor = selectedcolor or colors.red
  local optioncolor = optioncolor or colors.white
  local titlecolor = titlecolor or colors.blue

  local old_pad = input.peek()

  local selected = selected or 1
  local num = 18
  if title then
    num = 17
  end

  while true do
    print("peek, start, clear")
    local pad = input.peek()
    vita2d.start_drawing()
    vita2d.clear_screen()

    local p = 0

    local min = (selected <= num and 1 or selected - num + 1)
    local max = math.min(#options, (selected <= num and num or selected))

    if title then
      print("drawing title text")
      font_to_use:draw_text(0, 0, titlecolor, 30, title)
      p = 1
    end
    for i=min, max do
      if options[i] then
        print("Drawing item")
        font_to_use:draw_text(0, p * 30, i == selected and selectedoptcolor or optioncolor, 30, options[i])
      end
      p = p + 1
    end

    print("End drawing, swap buffers")
    vita2d.end_drawing()
    vita2d.swap_buffers()

    if hook then
      abort, res = hook(options[selected], old_pad, pad)
      if abort then
        return res, selected, abort
      end
    end

    if old_pad:up() and not pad:up() and selected > 1 then
      selected = selected - 1
      if options[selected] == nil then
        selected = selected - 1
      end
    elseif old_pad:down() and not pad:down() and selected < #options then
      selected = selected + 1
      if options[selected] == nil then
        selected = selected + 1
      end
    elseif old_pad:cross() and not pad:cross() then
      return options[selected], selected, false
    elseif old_pad:circle() and not pad:circle() then
      return nil, selected, false
    end

    old_pad = pad
  end
end

function ui.error(title, message, font)
  local title = " " .. (title or "") .. " "
  local font_to_use = font_custom or font or vita2d.load_font()

  -- Fixed variables.
  local vita_w = 960
  local vita_h = 544
  local half_w = vita_w/2
  local half_h = vita_h/2
  local maxlength = 64

  -- Math! Yay!
  local errorthing_w, errorthing_h = font_to_use:text_size(30, "/!\\")
  local titlewidth_w, titlewidth_h = font_to_use:text_size(30, title)

  local first_error_w = half_w - titlewidth_w/2 - errorthing_w
  local text_w = half_w - titlewidth_w/2
  local second_error_w = half_w + titlewidth_w/2

  local old_pad = input.peek()

  local messagearray = {}

  if not string.find(message, "\n$") then
    message = message .. "\n"
  end
  string.gsub(message, "(.-)\r?\n", function(line)
    for s in line:gmatch((".?"):rep(maxlength)) do
      if s then
        table.insert(messagearray, s)
      end
    end
  end)
  if #messagearray == 0 then
    for s in message:gmatch((".?"):rep(maxlength)) do
      if s then
        table.insert(messagearray, s)
      end
    end
  end

  while true do
    local pad = input.peek()

    vita2d.start_drawing()
    vita2d.clear_screen()

    font_to_use:draw_text(first_error_w, 0, colors.red, 30, "/!\\")
    font_to_use:draw_text(text_w, 0, colors.white, 30, title)
    font_to_use:draw_text(second_error_w, 0, colors.red, 30, "/!\\")

    for l, c in pairs(messagearray) do
      font_to_use:draw_text(0, l * 30, colors.white, 30, c)
    end

    vita2d.end_drawing()
    vita2d.swap_buffers()

    if old_pad:cross() and not pad:cross() then
      return true
    elseif old_pad:circle() and not pad:circle() then
      return false
    end

    old_pad = pad
  end
end

function ui.pager(text, title, displaylinenos, line, selectedcolor, normalcolor, font_custom)
  local text = text or ""
  local displaylinenos = displaylinenos or false
  local font_to_use = font_custom or font or vita2d.load_font()
  local selectedcolor = selectedcolor or colors.red
  local normalcolor = normalcolor or colors.blue

  local old_pad = input.peek()

  local line = line or 1

  local num = 18
  if title then
    num = 17
  end

  local lines = {}
  if type(text) == "string" then
    if not string.find(text, "\n$") then
      text = text.."\n"
    end
    local tmp_lines = string.lines(text)
    local count = #tmp_lines
    local numwidth = #(tostring(count))

    local maxlength = 62 - numwidth

    for n, line in pairs(tmp_lines) do
      local i = 0
      for s in line:gmatch((".?"):rep(maxlength)) do
        i = i + 1
        if displaylinenos then
          if i == 1 then
            local padded = string.rpad(tostring(n), numwidth)
            table.insert(lines, padded.."| ".. s)
          else
            if s and s ~= "" then
              table.insert(lines, string.rep(" ", numwidth).."| ".. s)
            end
          end
        else
          table.insert(lines, s)
        end
      end
    end
  elseif type(text) == "table" then
    lines = text
  end

  while true do
    local pad = input.peek()
    vita2d.start_drawing()
    vita2d.clear_screen()

    local p = 0

    local min = (line <= num and 1 or line - num + 1)
    local max = math.min(#lines, (line <= num and num or line))

    if title then
      font_to_use:draw_text(0, 0, colors.purple, 30, title)
      p = 1
    end
    for i=min, max do
      font_to_use:draw_text(0, p * 30, i == line and selectedcolor or normalcolor, 30, lines[i])
      p = p + 1
    end

    vita2d.end_drawing()
    vita2d.swap_buffers()

    if old_pad:up() and not pad:up() and line > 1 then
      line = line - 1
    elseif old_pad:down() and not pad:down() and line < #lines then
      line = line + 1
    elseif old_pad:cross() and not pad:cross() then
      return
    elseif old_pad:circle() and not pad:circle() then
      return
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

function ui.choose_file(startdir, title, selected, hook)
  print("ui.choose_file")
  local old_dir

  local startdir = string.gsub(startdir or "/", "/$", "")
  local path = {""}
  if startdir then
    for p in startdir:gmatch("[^/]+") do
      table.insert(path, p)
    end
  end
  while true do
    print("Getting list of files")
    local t = vfs.list(table.concat(path, "/") .. "/")
    if not string.find(table.concat(path, "/") .. "/", "^/$") then
      table.insert(t, 1, "..")
    end

    -- hack!
    if old_dir then
      selected = table.find(t, old_dir)
      old_dir = nil
    end

    res, selected, abort = ui.choose(t, title or table.concat(path, "/").."/", selected, function(res, old_pad, pad)
      print("file_chooser hook")
      if hook then
        return hook(res or "", old_pad, pad, table.concat(path, "/") .. ((res and "/" .. res) or "")), selected
      end
    end)
    if abort then
      return res, table.concat(path, "/"), selected
    end
    if res == ".." or res == nil then
      if #path > 1 then
        old_dir = table.remove(path)
      end
    else
      if vfs.isdir(table.concat(path, "/") .. "/" .. res) then
        table.insert(path, res)
        selected = 1
      else
        return (table.concat(path, "/") .. "/" .. res), table.concat(path, "/"), selected
      end
    end
  end
end
