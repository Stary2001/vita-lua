-- viewer.lua
local args = {...}
local file = args[1]
if file then
	if vfs.exists(file) then
		local data = assert(vfs.read(file))
		ui.pager(data, file, true)
	else
		--ui.error("viewer: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
		error("File ''" .. file .. "' could not be opened.")
	end
else
	error("Usage: viewer file")
end
