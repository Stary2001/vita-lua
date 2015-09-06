-- boot_ui
-- Loads up ui.choose_file and applies magic.
local physfsroot = "cache0:/"
local dir = "/VitaDefilerClient/Documents"
local binpath = "/bin"
local confpath = "/VitaDefilerClient/Documents/vitafm.cfg"

physfs.mount(physfsroot)

vitafm = {}

-- Helpers
local function file_extension(path)
  return tostring(path):match("^.+(%..+)$")
end

-- Config parser. Something like TOML and INI.
local function config_parse(file)
  local c = {}
  local subsect

  local f = physfs.open(file)
  if f then
    local data = f:read("*a")
    f:close()
    for n, line in pairs(string.lines(data)) do
      local s = line:match("^%[([^%]]+)%]$")
      if s then
        subsect = s
        c[s] = c[s] or {}
      else
        local k, v = line:match("^(.-)%s-=%s-(.+)$")
        if k and v then
          local nv = tonumber(v)
          if v == "true" then
            c[subsect][k] = true
          elseif v == "false" then
            c[subsect][k] = false
          elseif nv ~= nil then
            c[subsect][k] = nv
          else
            c[subsect][k] = v
          end
        elseif line ~= "" then
          table.insert(c[subsect], line)
        end
      end
    end
    return c
  else
    return nil
  end
end

-- Actual vitafm.programs
function vitafm.viewer(file)
  local f = physfs.open(file)
  if f ~= nil then
    local data = f:read("*a")
    f:close()
    ui.pager(data, file, true)
  else
    ui.error("Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
  end
end

function vitafm.lua(file)
  print("Lua file: ".. file)
  local f = physfs.open(file)
  if f ~= nil then
    local data = f:read("*a")
    f:close()
    local fn, err = loadstring(data)
    if err ~= nil then
      print("File manager: Lua syntax error: "..tostring(err))
      ui.error("Lua Syntax Error", "Error:\n" .. tostring(err))
      return
    end
    local success, err = pcall(fn)
    if not success then
      print("File manager: Lua script error: "..tostring(err))
      ui.error("Lua Script Error", "Error:\n" .. tostring(err))
      return
    end
  else
    ui.error("Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
  end
end

function vitafm.imgview(file, ext)
  local ext = file_extension(file)
  if ext == nil then
    ext = ui.choose({".png", ".jpg", ".bmp"}, "What format is the file?")
    if ext == nil then
      return
    end
  end
  local f = physfs.open(file)
  if f ~= nil then
    local data = f:read("*a")
    f:close()
    local image = vita2d.load_texture_data(ext:gsub("%.", ""), data)
    ui.view_image(image)
  else
    ui.error("Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
  end
end

function vitafm.font(file)
  local f = physfs.open(file)
  if f ~= nil then
    local data = f:read("*a")
    f:close()
    font = vita2d.load_font_data(data)
  else
    ui.error("Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
  end
end

function vitafm.mount(file)
  physfs.mount(physfsroot .. file)
end

-- types
local types = {
  [".txt"] = "viewer %f",
  -- Lua
  [".lua"] = "lua %f",

  -- Images
  [".png"] = "imgview %f",
  [".jpeg"] = "imgview %f",
  [".jpg"] = "imgview %f",
  [".bmp"] = "imgview %f",

  -- Fonts
  [".ttf"] = "font %f",

  -- Physfs archives.
  [".zip"] = "mount %f",

  -- Ask for handler
  ["*"] = "ask %f %e"
}
table.sort(types)

-- "Program" Registration.
vitafm.programs = {
  ["viewer"] = vitafm.viewer,
  ["lua"] = vitafm.lua,
  ["mount"] = vitafm.mount,
  ["imgview"] = vitafm.imgview,
  ["font"] = vitafm.font
}
local function add_programs(path)
  local dir = physfs.list(path)
  for k, v in pairs(dir) do
    if v:find("%.lua$") then
      local filepath = path.."/"..v
      local f = physfs.open(filepath)
      if f ~= nil then
        local data = f:read("*a")
        f:close()
        local fn, err = loadstring(data)
        if err ~= nil then
          print("File manager: Lua plugin load error: "..tostring(err))
        else
          vitafm.programs[v:gsub("%.lua$", "")] = fn
        end
      end
    end
  end
end

function vitafm.exec(prog, ...) -- Global, so other vitafm.programs that get loaded by this can run others.
  return vitafm.programs[prog](...)
end

function vitafm.run_shell(command, vars)
  local succ, split = os.shellparse(command)
  if not succ then
    ui.error("Command Parser Error", "Error:\n" .. split)
    return
  end
  local prog = split[1]
  table.remove(split, 1)

  local args = {}
  for k, v in pairs(split) do
    local val
    local nv = tonumber(val)
    if v == "true" then
      val = true
    elseif v == "false" then
      val = false
    elseif nv ~= nil then
      val = nv
    else
      local tmp = v
      for varname, replacement in pairs(vars) do
        --tmp = tmp:gsub(varname:gsub("%%", "%%%1"), replacement)
        tmp = tmp:gsub(varname, replacement)
      end
      val = tmp
    end
    args[k] = val
  end
  return vitafm.exec(prog, unpack(args))
end

function vitafm.call_prog(command, file, ext)
  return vitafm.run_shell(command, {
    ["%%f"] = file,
    ["%%e"] = ext
  })
end

-- Ask for program to launch it with.
function vitafm.ask(file, ext)
  if not string.find(file or "", "^/") then
    return
  end
  local ext = file_extension(file)
  local keys = {}
  local i = 0
  local sel = 1
  for k, v in pairs(types) do
    if k ~= "*" then
      i = i + 1
      if k == ext then
        sel = i
      end
      table.insert(keys, k .. " - " .. v)
    end
  end
  local l = #keys
  keys[l+1] = nil
  keys[l+2] = "Open with..."
  keys[l+3] = "Back"
  while true do
    opt = ui.choose(keys, "Launch as... (Extension: ".. (ext or "none") .. ")", sel)
    if opt then
      res = opt:gsub(" - .-$", "")
      if opt == "Back" then
        return
      elseif opt == "Open with..." then
        prog = ui.choose(table.keys(vitafm.programs), "Open with...")
        if prog then
          return vitafm.call_prog(prog.." %f", file)
        end
        return
      elseif types[res] then
        return vitafm.call_prog(types[res], file, res)
      end
    else
      return
    end
  end
end
vitafm.programs["ask"] = vitafm.ask

-- Parse Config
local function parse_config(path)
  print("Looking for config...")
  if physfs.exists(path) then
    print("Loading config...")
    local conf = config_parse(path)
    if type(conf.filetypes) == "table" then
      types = conf.filetypes
    end
    if type(conf.mount) == "table" then
      for k, v in pairs(conf.mount) do
        physfs.mount(v)
      end
    end
    print("Loaded config.")
  else
    print("Not found.")
  end
end
parse_config(confpath)

-- Main loop.
local selected
while true do
  if physfs.is_dir(binpath) then
    add_programs(binpath)
  end
  file, dir, selected = ui.choose_file(dir, nil, selected, (function(sel, old_pad, pad, path)
    if old_pad:triangle() and not pad:triangle() then -- "Open as" menu
      vitafm.programs["ask"](path, file_extension(path))
      return true, nil
    elseif old_pad:square() and not pad:square() then -- Tool menu
      local title = "VitaFM Menu"
      local menuitems = {
        "Run Program",
        nil,
        "Exit VitaFM",
        "Back"
      }
      res = ui.choose(menuitems, title)
      if res == "Run Program" then
        prog = ui.choose(table.keys(vitafm.programs), "Open Program...")
        if prog then
          return vitafm.exec(prog)
        end
      elseif res == "Exit VitaFM" then
        os.exit(0)
      end
      return true, nil
    end
  end))
  if file ~= nil then
    local ext = file_extension(file)
    if types[ext] then
      vitafm.call_prog(types[ext], file, ext)
    elseif types["*"] then
      vitafm.call_prog(types["*"], file, ext)
    end
  end
end
