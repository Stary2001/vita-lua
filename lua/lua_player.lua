-- lua player
local bit = require 'bit'
local ffi = require 'ffi'

local function current_time()
  return os.clock() * 1000
end

player_is_psp = true

function start_player()
  vita2d.init()
  local monospace_font = vita2d.load_font()
  local prop_font = vita2d.load_font()

  System = {}
  System.setCpuSpeed = function () end
  System.currentDirectory = function(p) if p == nil then return fs.working_dir else print("new dir is " .. p) fs.chdir(p) end end
  System.listDirectory = function(p) print("listing " .. tostring(p) .. " " .. fs.working_dir) if p == nil then return fs.list(fs.working_dir) else return fs.list(p) end end
  System.createDirectory = fs.mkdir
  System.removeDirectory = fs.rmdir
  System.removeFile = function(path)
    if fs.is_relative(path) then
      path = fs.working_dir + "/" + path
    end
    os.remove(path)
  end
  System.draw = vita2d.start_drawing
  System.endDraw = vita2d.end_drawing

  System.MSGDIALOG_RESULT_YES = 0
  System.MSGDIALOG_RESULT_NO = 1
  System.MSGDIALOG_RESULT_BACK = 2
  System.MSGDIALOG_RESULT_UNKNOWN1 = 3
  System.msgDialog = function(text, default) -- hack
    return System.MSGDIALOG_RESULT_NO
  end

  System.quit = function()
    os.exit(0)
  end

  Timer = {}
  Timer.new = function(start)
    t = { t = 0, off = start and start or 0}
    setmetatable(t, { __index = Timer })
    return t
  end

  Timer.start = function(self)
    if self.t ~= 0 then
      return self:time()
    else
      self.t = math.round(os.clock() * 1000)
      return self.off
    end
  end

  Timer.time = function(self)
    if self.t ~= 0 then
      return self.off + current_time() - self.t
    else
      return self.off
    end
  end

  Timer.stop = function(self)
    if self.t ~= 0 then
      self.off = self.off + current_time() - self.t
      self.t = 0
    end
    return self.off
  end

  Timer.reset = function(self, start)
    local tmp
    tmp = self:time()

    self.t = 0
    self.off = start and start or 0
    return tmp
  end

  Color = {}
  Color.new = function(r, g, b, a)
    if a == nil then a = 255 end
    t = { r = r, g = g, b = b, a = a}
    setmetatable(t, Color)
    return t
  end

  Color.colors = function(self)
    return {self.r,self.g,self.b,self.a}
  end

  Color.__equals = function(a, b)
    return a.r == b.r and a.g == b.g and a.b == g.b and a.a == b.a
  end

  Image = {}

  local function to_rgba(c)
    return bit.bor(bit.lshift(c.a, 24), bit.lshift(c.b, 16), bit.lshift(c.g, 8), c.r)
  end

  local function to_color(rgba)
    return Color.new(bit.band(rgba, 0xff), bit.rshift(bit.band(rgba, 0x0000ff00), 8), bit.rshift(bit.band(rgba, 0x00ff0000), 16), bit.rshift(bit.band(rgba, 0xff000000), 24))
  end

  screen = {}
  screen.fillRect = function(x,y,w,h,c)
    if c == nil then
      c = Color.new(0,0,0)
    end
    vita2d.draw_rectangle(x,y,w,h,to_rgba(c))
  end

  screen.drawLine = function(x0,y0,x1,y1,c)
    if c == nil then
      c = Color.new(0,0,0)
    end
    vita2d.draw_rectangle(x0,y0,x1,y1,to_rgba(c))
  end

  screen.flip = vita2d.swap_buffers
  screen.width = function()
    if player_is_psp then
      return 480
    else
      return 960
    end
  end

  screen.height = function()
    if player_is_psp then
      return 272
    else
      return 544
    end
  end

  screen.print = function(self, x, y, text, c)
    if c == nil then
      c = Color.new(0,0,0)
    end
    monospace_font:draw_text(x, y, text, to_rgba(c))
  end

  screen.fontPrint = function(self, font, x, y, text, c)
    if c == nil then
      c = Color.new(0,0,0)
    end
    font:draw_text(x, y, text, to_rgba(c))
  end

  screen.pixel = function(self, x, y, c)
    pixels = ffi.cast("uint32_t *", vita2d.get_framebuffer())
    if c == nil then
      return to_color(pixels[(y * 960) + x])
    else
      pixels[(y * 960) + x] = to_rgba(c)
    end
  end

  screen.clear = function(self) vita2d.clear_screen() end
  screen.slowClear = screen.clear

  setmetatable(screen, { __index = Image })

  Image.createEmpty = function(width, height)
    t = { tex = vita2d.create_empty_texture(width, height) }
    setmetatable(t, { __index = Image } )
    return t
  end

  Image.load = function(filename)
    t = { tex = vita2d.load_texture(filename) }
    setmetatable(t, { __index = Image })
    return t
  end

  Image.width = function(self) return self.tex:width() end
  Image.height = function(self) return self.tex:height() end

  Image.blit = function(self, x, y, source, alpha, sx, sy, w, h)
    if sx == nil and sy == nil and w == nil and h == nil then
      sx = 0
      sy = 0
      w = source:width()
      h = source:height()
    end

    if alpha == nil then
      alpha = 1
    end

    if self == screen then
      source.tex:draw_part(x, y, sx, sy, w, h)
    else
      error("blit between images isn't implemented!")
    end
  end

  Image.pixel = function(self, x, y, c)
    pixels = ffi.cast("uint32_t *", self.tex:data())
    if c == nil then
      return to_color(pixels[(y * self.tex:width()) + x])
    else
      pixels[(y * self.tex:width()) + x] = to_rgba(c)
    end
  end
  
  Image.clear = function(self, c)
    if c == nil then
      c = Color.new(0, 0, 0, 0)
    end
    c = to_rgba(c)
    pixels = ffi.cast("uint32_t *", self.tex:data())
    print(debug.traceback())
    print("clear " .. self.tex:stride())
    print(tostring(self.tex:format()))
    for y = 0, self.tex:height()-1 do
      print(y)
      for x = 0, self.tex:width()-1 do
        pixels[(y * self.tex:width()) + x] = c
      end
    end
  end

  Image.save = function(self)
    -- hack: stubbed out
  end

  Image.free = function(self)
    vita2d.free_texture(self.tex)
    self.tex = nil
  end

  Controls = {}

  Controls.__equals = function(a,b)
    return a:buttons() == b:buttons()
  end

  Controls.read = function()
    t = {buf = input.peek()}
    setmetatable(t, { __index = Controls })
    return t
  end

  Controls.buttons = function(self)
    return self.buf.buttons
  end

  funcs = {"select", "start", "up", "right", "down", "left", "triangle", "circle", "cross", "square"}
  for k,v in pairs(funcs) do
    Controls[v] = function (self) return bit.band(self:buttons(), buttons[v]) ~= 0 end
  end

  Controls.l = function(self) return bit.band(self:buttons(), buttons.l_trigger) end
  Controls.r = function(self) return bit.band(self:buttons(), buttons.r_trigger) end

  Controls.analogX = function(self)
    return self.buf.lx
  end

  Controls.analogY = function(self)
    return self.buf.ly
  end

  os.time = function() return 0 end -- hack - random is no longer random
end
