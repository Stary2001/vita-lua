-- mount.lua
local args = {...}
if args[1] and args[2] then
	return phyfs.mount(args[1], args[2])
else
	error("Usage: mount <path> <vfsid>")
end
