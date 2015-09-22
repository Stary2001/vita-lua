-- font.lua
local args = {...}
local file = args[1]
local f
if string.find(file, "^/") then
	f = physfs.open(file)
else
	f = io.open(file, "r")
end
if f ~= nil then
	local data = f:read("*a")
	f:close()
	font = vita2d.load_font_data(data)
else
	--ui.error("font: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
	error("File ''" .. file .. "' could not be opened.")
end
