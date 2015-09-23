-- viewer.lua
local args = {...}
local file = args[1]
if file then
	local f
	if string.find(file, "^/") then
		f = physfs.open(file)
	else
		f = io.open(file, "r")
	end
	if f ~= nil then
		local data = f:read("*a")
		f:close()
		ui.pager(data, file, true)
	else
		--ui.error("viewer: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
		error("File ''" .. file .. "' could not be opened.")
	end
else
	error("Usage: viewer file")
end
