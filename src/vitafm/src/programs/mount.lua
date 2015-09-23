-- mount.lua
local args = {...}
if args[1] then
	return phyfs.mount(args[1], args[2])
else
	error("Usage: mount path")
end
