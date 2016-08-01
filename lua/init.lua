package.path = "?;?.lua;app0:/lib/?;app0:/lib/?.lua"
local libs = {"audio", "battery", "colors", "fs", "hash", "http", "input", "misc", "physfs", "touch", "ui", "vita2d", "vitafm"}
for _, lib in pairs(libs) do
	print("require()-ing "..lib)
	require(lib)
end
