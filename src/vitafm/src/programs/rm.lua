-- rm.lua
local args = {...}
local file = args[1]
if file then
	assert(vfs.delete(file))
else
	error("Usage: rm file")
end
