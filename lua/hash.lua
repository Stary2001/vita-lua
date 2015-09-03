-- hash

local ffi = require 'ffi'

ffi.cdef [[
  unsigned long crc32 (unsigned long crc, const char *buf, unsigned int len);
]]

hash = {}

function hash.crc32(data, crc)
  if crc == nil then
    crc = ffi.C.crc32(0, nil, 0)
  end
  return ffi.C.crc32(crc, data, #data)
end

function hash.file_crc32(file)
  local crc = ffi.C.crc32(0, nil, 0) -- init crc
  local f = io.open(file, "r")
  if f == nil then return end

  while true do
    local block = f:read(8192)
    if not block then break end
    crc = ffi.C.crc32(crc, block, #block)
  end

  return crc
end
