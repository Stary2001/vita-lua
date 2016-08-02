-- mkdir.Lua
local args = {...}
local file = args[1]
if file then
	if not vfs.exists(file) then
		assert(vfs.mkdir(file))
	else
		error("File or directory already exists!")
	end
else
	error("Usage: mkdir directory")
end
