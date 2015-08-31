ffi.cdef [[
	int sceKernelDelayThread(unsigned int delay);
]]

function os.sleep(s)
  os.usleep(s * 1000000)
end

function os.usleep(us)
  ffi.C.sceKernelDelayThread(us)
end
