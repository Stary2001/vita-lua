-- rmdir.Lua
local args = {...}
local file = args[1]
if file then
	if string.find(file, "^/") then
		return physfs.rmdir(file)
	else
		return fs.rmdir(file)
	end
else
	error("Usage: rmdir directory")
end
