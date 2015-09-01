-- misc
local ffi = require 'ffi'

ffi.cdef [[
	typedef uint64_t SceUInt64;
	typedef SceUInt64 SceKernelSysClock;
	int sceKernelDelayThread(unsigned int delay);
	int sceKernelGetProcessTime(SceKernelSysClock *c);
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

-- from http://lua-users.org/wiki/SimpleRound

function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
