-- rmdir.Lua
local args = {...}
local file = args[1]
if string.find(file, "^/") then
	return physfs.rmdir(file)
else
	return fs.rmdir(file)
end
