-- font.lua
local args = {...}
local file = args[1]
if file then
	if vfs.exists(file) then
		local data = assert(vfs.read(file))
		font = vita2d.load_font_data(data)
	else
		--ui.error("font: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
		error("File ''" .. file .. "' could not be opened.")
	end
else
	error("Usage: font font.ttf")
end
