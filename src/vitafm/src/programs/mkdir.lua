-- mkdir.Lua
local args = {...}
local file = args[1]
if string.find(file, "^/") then
	return physfs.mkdir(file)
else
	return fs.mkdir(file)
end
