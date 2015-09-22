-- rm.lua
local args = {...}
local file = args[1]
if string.find(file, "^/") then
	return physfs.delete(file)
else
	return os.remove(file)
end
