-- font.lua
local args = {...}
local f = physfs.open(args[1])
if f ~= nil then
	local data = f:read("*a")
	f:close()
	font = vita2d.load_font_data(data)
else
	--ui.error("font: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
	error("File ''" .. file .. "' could not be opened.")
end
