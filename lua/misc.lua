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

-- Table find
function table.find(t, val)
  for k,v in pairs(t) do
    if v == val then
      return k
    end
  end
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
