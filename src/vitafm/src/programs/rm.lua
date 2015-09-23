-- rm.lua
local args = {...}
local file = args[1]
if file then
	if string.find(file, "^/") then
		return physfs.delete(file)
	else
		return os.remove(file)
	end
else
	error("Usage: rm file")
end
