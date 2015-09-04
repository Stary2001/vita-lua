-- ui
ui = {}
function ui.choose(options, title, titlecolor, selectedoptcolor, optioncolor, font_custom)
  local font_to_use = font_custom or font or vita2d.load_font()
  local selectedoptcolor = selectedcolor or colors.red
  local optioncolor = optioncolor or colors.white
  local titlecolor = titlecolor or colors.blue

  local old_pad = input.peek()

  local selected = 1
  local num = 18
  while true do
    pad = input.peek()
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

    if old_pad:up() and not pad:up() and selected > 1 then
      selected = selected - 1
    elseif old_pad:down() and not pad:down() and selected < #options then
      selected = selected + 1
    elseif old_pad:cross() and not pad:cross() then
      return options[selected]
    elseif old_pad:circle() and not pad:circle() then
      return nil
    end

    old_pad = pad
  end
end
