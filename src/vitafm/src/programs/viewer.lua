local args = {...}
local f = physfs.open(args[1])
if f ~= nil then
	local data = f:read("*a")
	f:close()
	ui.pager(data, file, true)
else
	--ui.error("viewer: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
	error("File ''" .. file .. "' could not be opened.")
end
