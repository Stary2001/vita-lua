-- lcall.lua
local args = {...}
if not args[1] then
	return nil
end

local f = args[1]
table.remove(args, 1)

f(unpack(args))
