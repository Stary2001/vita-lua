package.path = "?;?.lua;app0:lua/?;app0:lua/?.lua"
local libs = {"audio", "battery", "colors", "fs", "hash", "http", "input", "misc", "physfs", "touch", "ui", "vita2d", "vitafm"}
for k,v in pairs(libs) do
	require(v)
end