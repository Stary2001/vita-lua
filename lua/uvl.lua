-- misc
local ffi = require 'ffi'

ffi.cdef [[
void *uvl_alloc_code_mem(unsigned int *p_len);
void uvl_unlock_mem(void);
void uvl_lock_mem(void);
void uvl_flush_icache(void *addr, unsigned int len);
int uvl_load(const char *path);
void uvl_exit(int status);
int uvl_log_write(const void* buffer, unsigned int size);
]]

uvl = {}

function uvl.load(path)
  return ffi.C.uvl_load(path) == 0
end

function uvl.exit(status)
  vita2d.fini() -- Some cleanup.
  physfs.deinit()

  ffi.C.uvl_exit(tonumber(status))
end

os.exit = uvl.exit -- Alias it to os.exit
