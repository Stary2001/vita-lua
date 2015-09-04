-- boot_ui
-- Loads up ui.choose_file and applies magic.
local dir = "/VitaDefilerClient/Documents"
local physfsroot = "cache0:/"

physfs.mount(physfsroot)

-- Helpers
local function file_extension(path)
	return path:match("^.+(%..+)$")
end

-- Actual handlers
local function handler_lua(file, ext)
	print("Lua file: ".. file)
	local f = physfs.open(file)
	if f ~= nil then
		local data = f:read("*a")
		f:close()
	  local fn, err = loadstring(data)
		if err ~= nil then
			print("File manager: Lua syntax error: "..tostring(err))
			return
		end
		local success, err = pcall(fn)
		if not success then
			print("File manager: Lua script error: "..tostring(err))
			return
		end
	end
end

local function handler_image(file, ext)
	local f = physfs.open(file)
	if f ~= nil then
		local data = f:read("*a")
		f:close()
		local image = vita2d.load_texture_data(ext:gsub("%.", ""), data)
		ui.view_image(image)
	end
end

local function handler_mount(file, ext)
	physfs.mount(physfsroot .. file)
end

-- types
local types = {
	-- Lua
	[".lua"] = "lua",
	-- Images
	[".png"] = "image",
	[".jpeg"] = "image",
	[".jpg"] = "image",
	[".bmp"] = "image",
	-- Physfs archives.
	[".zip"] = "mount",
	["*"] = "ask"
}
table.sort(types)

-- Handler Registration.
local handlers = {
	["lua"] = handler_lua,
	["mount"] = handler_mount,
	["image"] = handler_image
}
handlers["ask"] = (function(file, ext)
	local keys = {}
	local i = 0
	local sel = 1
	for k, v in pairs(types) do
		if k ~= "*" then
			i = i + 1
			if k == ext then
				sel = i
			end
			table.insert(keys, k .. " - " .. v)
		end
	end
	table.insert(keys, "Back")
	while true do
		opt = ui.choose(keys, "Launch as... (Extension: ".. (ext or "none") .. ")", sel)
		if opt then
			res = opt:gsub(" - .-$", "")
			if opt == "Back" then
				return
			elseif types[res] then
				handlers[types[res]](file, res)
			end
		else
			return
		end
	end
end)

local selected

-- Loop.
while true do
	file, dir, selected = ui.choose_file(dir, nil, selected, (function(sel, old_pad, pad, path)
		if old_pad:triangle() and not pad:triangle() then
			handlers["ask"](path, file_extension(path))
			return true, nil
		end
	end))
	if file ~= nil then
		ext = file_extension(file)
		if types[ext] then
			handlers[types[ext]](file, ext)
		elseif types["*"] then
			handlers[types["*"]](file, ext)
		end
	end
end
