-- imgview.lua
local args = {...}
if args[1] then
	local ext = file_extension(args[1])
	if ext == nil then
		ext = ui.choose({".png", ".jpg", ".bmp"}, "What format is the file?")
		if ext == nil then
			return
		end
	end
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
		local image = vita2d.load_texture_data(ext:gsub("%.", ""), data)
		ui.view_image(image)
	else
		--ui.error("imgview: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
		error("File ''" .. file .. "' could not be opened.")
	end
else
	error("Usage: imgview image [png/jpg/bmp]")
end
