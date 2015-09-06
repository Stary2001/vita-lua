-- misc
local ffi = require 'ffi'

ffi.cdef [[
  typedef uint64_t SceUInt64;
  typedef SceUInt64 SceKernelSysClock;
  int sceKernelDelayThread(unsigned int delay);
  int sceKernelGetProcessTime(SceKernelSysClock *c);
  int sceKernelExitProcess(int r);
]]

function os.sleep(s)
  os.usleep(s * 1000000)
end

function os.usleep(us)
  ffi.C.sceKernelDelayThread(us)
end

function os.clock()
  c = ffi.new('SceKernelSysClock[1]')
  ffi.C.sceKernelGetProcessTime(c)
  return tonumber(c[0]) / 1000000
end

function os.exit(r)
  ffi.C.sceKernelExitProcess(r)
end

-- from http://stackoverflow.com/questions/28664139/lua-split-string-into-words-unless-quoted
function os.shellparse(text)
  local res = {}
  local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
  for str in text:gmatch("%S+") do
    local squoted = str:match(spat)
    local equoted = str:match(epat)
    local escaped = str:match([=[(\*)['"]$]=])
    if squoted and not quoted and not equoted then
      buf, quoted = str, squoted
    elseif buf and equoted == quoted and #escaped % 2 == 0 then
      str, buf, quoted = buf .. ' ' .. str, nil, nil
    elseif buf then
      buf = buf .. ' ' .. str
    end
    if not buf then
      table.insert(res, (str:gsub(spat,""):gsub(epat,"")))
    end
  end
  if buf then
    return false, "Missing matching quote for "..buf
  end
  return true, res
end

-- from http://lua-users.org/wiki/SimpleRound
function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- simple lines()
function string.lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

-- String padding
function string.lpad(str, len, chr)
  local char = chr or " "
  return str .. string.rep(char, len - #str)
end
function string.rpad(str, len, chr)
  local char = chr or " "
  return string.rep(char, len - #str) .. str
end

-- Table find
function table.find(t, val)
  for k,v in pairs(t) do
    if v == val then
      return k
    end
  end
end

-- Small table helpers.
function table.keys(t)
  local res = {}
  for k in pairs(t) do
    table.insert(res, k)
  end
  return res
end
function table.iterate(t, f)
  for k, v in pairs(t) do
    f(k, v)
  end
end
function table.map(t, f)
  local rest = {}
  for k, v in pairs(t) do
    rest[k] = f(k, v)
  end
end
