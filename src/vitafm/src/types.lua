-- List of types assigned in vitafm as default.
vitafm.types = {
	-- Lua files
	[".lua"] = "lua %f",

	-- Text files
	[".txt"] = "viewer %f",
	[".log"] = "viewer %f",

	-- Image files
	[".png"] = "imgview %f",
	[".jpeg"] = "imgview %f",
	[".jpg"] = "imgview %f",
	[".bmp"] = "imgview %f",

	-- Fonts
	[".ttf"] = "font %f",

	-- Physfs archives.
	[".zip"] = "mount %F",

	-- Vita Homebrew files
	[".velf"] = "uvloader %F",

	-- Ask for handler
	["*"] = "ask %f %e"
}
